import { GoogleGenerativeAI } from "@google/generative-ai";
import { config } from "dotenv"; // Load .env
import { body, validationResult } from "express-validator";
import Dream from "../models/Dream.js";
import User from "../models/User.js";
import { v2 as cloudinary } from "cloudinary";
import { protect } from "./authController.js";

// Load environment variables
config();

// Initialize Gemini API client
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export const generateDream = [
  protect,
  body("prompt").notEmpty().withMessage("Prompt is required"),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { prompt } = req.body;

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({ message: "Gemini API key not configured in .env" });
    }

    try {
      console.log("Generating image with prompt:", prompt);

      // Use Gemini 2.5 Flash for image generation
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      // Generate image and expect a public URL in the text field
      const result = await model.generateContent({
        contents: [
          {
            role: "user",
            parts: [
              {
                text: `Generate a high-quality, realistic image (1024x1024) of: ${prompt}. Return a publicly accessible image URL.`,
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 1024,
        },
      });
      console.log("Full Gemini API result:", JSON.stringify(result, null, 2));

      const response = result.response;

      if (!response || !response.candidates || response.candidates.length === 0) {
        throw new Error("No candidates returned from Gemini API");
      }

      const imageUrl = response.candidates[0].content.parts[0].text;

      if (!imageUrl || !imageUrl.startsWith("http")) {
        throw new Error("Invalid image URL returned from Gemini API");
      }
      console.log("Generated image URL:", imageUrl);

      // Save to MongoDB (no need to upload to Cloudinary manually)
      const dream = await Dream.create({
        user: req.user._id,
        prompt,
        imageUrl,
        isPublic: false,
      });

      await User.findByIdAndUpdate(req.user._id, { $push: { dreams: dream._id } });

      console.log("Dream created in DB:", dream._id);

      res.status(201).json({
        _id: dream._id,
        prompt,
        imageUrl,
        createdAt: dream.createdAt,
        likes: 0,
        dislikes: 0,
      });
    } catch (error) {
      console.error("Error generating dream:", {
        message: error.message,
        code: error.code,
        details: error,
      });

      if (error.code === "rate_limit_exceeded") {
        return res.status(429).json({ message: "API rate limit exceeded. Try again later." });
      }

      if (error.code === "invalid_api_key") {
        return res.status(401).json({ message: "Invalid Gemini API key. Check your credentials." });
      }

      res.status(500).json({ message: "Error generating dream image", details: error.message });
    }
  },
];


// Get User's Dreams (unchanged)
export const getUserDreams = [
  protect,
  async (req, res) => {
    try {
      const dreams = await Dream.find({ user: req.user._id })
        .sort({ createdAt: -1 })
        .select("-sharedWith -likes -dislikes");
      const formattedDreams = dreams.map((dream) => ({
        ...dream.toObject(),
        likes: dream.likes?.length || 0,
        dislikes: dream.dislikes?.length || 0,
      }));
      res.json(formattedDreams);
    } catch (error) {
      res.status(500).json({ message: "Error fetching dreams" });
    }
  },
];

// Share Dream (unchanged)
export const shareDream = [
  protect,
  body("dreamId").isMongoId().withMessage("Invalid dream ID"),
  body("shareWith").optional().isMongoId().withMessage("Invalid user ID"),
  body("isPublic").optional().isBoolean().withMessage("isPublic must be a boolean"),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { dreamId, shareWith, isPublic } = req.body;

    try {
      const dream = await Dream.findOne({ _id: dreamId, user: req.user._id });
      if (!dream) return res.status(404).json({ message: "Dream not found" });

      if (isPublic !== undefined) {
        dream.isPublic = isPublic;
        if (isPublic) dream.sharedWith = []; // Clear private shares when public
      }
      if (shareWith && !dream.isPublic) {
        if (!dream.sharedWith.includes(shareWith)) {
          dream.sharedWith.push(shareWith);
        }
      }

      await dream.save();
      res.json({
        message: "Dream shared successfully",
        dream: {
          ...dream.toObject(),
          likes: dream.likes.length,
          dislikes: dream.dislikes.length,
        },
      });
    } catch (error) {
      res.status(500).json({ message: "Error sharing dream" });
    }
  },
];

// Get Public Dreams (unchanged)
export const getPublicDreams = async (req, res) => {
  try {
    const dreams = await Dream.find({ isPublic: true })
      .populate("user", "username")
      .sort({ createdAt: -1 });
    const formattedDreams = dreams.map((dream) => ({
      ...dream.toObject(),
      likes: dream.likes.length,
      dislikes: dream.dislikes.length,
    }));
    res.json(formattedDreams);
  } catch (error) {
    res.status(500).json({ message: "Error fetching public dreams" });
  }
};

// Like Dream (unchanged)
export const likeDream = [
  protect,
  body("dreamId").isMongoId().withMessage("Invalid dream ID"),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { dreamId } = req.body;

    try {
      const dream = await Dream.findById(dreamId);
      if (!dream || !dream.isPublic) return res.status(404).json({ message: "Public dream not found" });

      const userId = req.user._id;
      const alreadyLiked = dream.likes.includes(userId);
      const alreadyDisliked = dream.dislikes.includes(userId);

      if (alreadyLiked) {
        dream.likes.pull(userId);
      } else {
        dream.likes.push(userId);
        if (alreadyDisliked) dream.dislikes.pull(userId);
      }

      await dream.save();
      res.json({
        message: alreadyLiked ? "Like removed" : "Liked successfully",
        likes: dream.likes.length,
        dislikes: dream.dislikes.length,
      });
    } catch (error) {
      res.status(500).json({ message: "Error liking dream" });
    }
  },
];

// Dislike Dream (unchanged)
export const dislikeDream = [
  protect,
  body("dreamId").isMongoId().withMessage("Invalid dream ID"),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { dreamId } = req.body;

    try {
      const dream = await Dream.findById(dreamId);
      if (!dream || !dream.isPublic) return res.status(404).json({ message: "Public dream not found" });

      const userId = req.user._id;
      const alreadyDisliked = dream.dislikes.includes(userId);
      const alreadyLiked = dream.likes.includes(userId);

      if (alreadyDisliked) {
        dream.dislikes.pull(userId);
      } else {
        dream.dislikes.push(userId);
        if (alreadyLiked) dream.likes.pull(userId);
      }

      await dream.save();
      res.json({
        message: alreadyDisliked ? "Dislike removed" : "Disliked successfully",
        likes: dream.likes.length,
        dislikes: dream.dislikes.length,
      });
    } catch (error) {
      res.status(500).json({ message: "Error disliking dream" });
    }
  },
];

export const searchUserDreams = [
  protect,
  async (req, res) => {
    try {
      const { query } = req.query;
      if (!query) {
        return res.status(400).json({ message: "Query parameter is required" });
      }

      // Case-insensitive search in user's dreams
      const dreams = await Dream.find({
        user: req.user._id,
        prompt: { $regex: query, $options: "i" }, 
      }).sort({ createdAt: -1 });

      const formattedDreams = dreams.map((dream) => ({
        ...dream.toObject(),
        likes: dream.likes?.length || 0,
        dislikes: dream.dislikes?.length || 0,
      }));

      res.json(formattedDreams);
    } catch (error) {
      console.error("Error searching dreams:", error);
      res.status(500).json({ message: "Error searching dreams" });
    }
  },
];

export const searchPublicDreams = async (req, res) => {
  try {
    const { query, page = 1, limit = 10 } = req.query;

    const filter = { isPublic: true };
    if (query) {
      filter.prompt = { $regex: query, $options: "i" };
    }

    const dreams = await Dream.find(filter)
      .populate("user", "username")
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const formattedDreams = dreams.map((dream) => ({
      ...dream.toObject(),
      likes: dream.likes.length,
      dislikes: dream.dislikes.length,
    }));

    res.json({
      page: parseInt(page),
      limit: parseInt(limit),
      results: formattedDreams,
    });
  } catch (error) {
    console.error("Error searching public dreams:", error);
    res.status(500).json({ message: "Error searching public dreams" });
  }
};

export const searchDreams = [
  protect,
  async (req, res) => {
    try {
      const { query, isPublic, username, page = 1, limit = 10, sortBy = "recent" } = req.query;

      // Build the filter
      const filter = {};
      if (query) filter.prompt = { $regex: query, $options: "i" };
      if (isPublic !== undefined) filter.isPublic = isPublic === "true";

      // Filter by specific user if username is provided
      if (username) {
        const user = await User.findOne({ username });
        if (!user) return res.status(404).json({ message: "User not found" });
        filter.user = user._id;
      }

      // Pagination calculations
      const skip = (page - 1) * limit;

      // Sorting
      const sort = {};
      if (sortBy === "popular") {
        sort.likes = -1; // most liked first
      } else {
        sort.createdAt = -1; // default: newest first
      }

      // Fetch dreams
      const dreams = await Dream.find(filter)
        .populate("user", "username")
        .sort(sort)
        .skip(Number(skip))
        .limit(Number(limit));

      const total = await Dream.countDocuments(filter);

      // Format response
      const formattedDreams = dreams.map(dream => ({
        ...dream.toObject(),
        likes: dream.likes.length,
        dislikes: dream.dislikes.length,
      }));

      res.json({
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / limit),
        dreams: formattedDreams,
      });

    } catch (error) {
      console.error("Error searching dreams:", error);
      res.status(500).json({ message: "Error searching dreams" });
    }
  },
];

export const getSharedDreams = [
  protect,
  async (req, res) => {
    try {
      // Find dreams where current user is in the sharedWith array
      const dreams = await Dream.find({ sharedWith: req.user._id })
        .populate("user", "username")
        .sort({ createdAt: -1 });

      const formattedDreams = dreams.map(dream => ({
        ...dream.toObject(),
        likes: dream.likes.length,
        dislikes: dream.dislikes.length,
      }));

      res.json(formattedDreams);
    } catch (error) {
      console.error("Error fetching shared dreams:", error);
      res.status(500).json({ message: "Error fetching shared dreams" });
    }
  },
];
