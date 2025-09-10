import { GoogleGenerativeAI } from "@google/generative-ai";
import { config } from "dotenv"; // ES Module import for dotenv

// Load environment variables
config();

// Initialize Gemini API client
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

// Test the API
model.generateContent("Hello, test the API")
  .then((response) => console.log("Success:", response))
  .catch((error) => console.error("Error:", error));