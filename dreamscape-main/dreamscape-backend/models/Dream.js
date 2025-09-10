import mongoose from "mongoose";

const dreamSchema = mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    prompt: { type: String, required: true },
    imageUrl: { type: String, required: true }, // URL of the generated image
    isPublic: { type: Boolean, default: false }, // If true, visible to all and likeable
    sharedWith: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }], // Private shares
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }], // Users who liked
    dislikes: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }], // Users who disliked
  },
  { timestamps: true }
);

dreamSchema.index({ user: 1, createdAt: -1 }); // For fast user dream queries
dreamSchema.index({ isPublic: 1, createdAt: -1 }); // For public dream feeds

export default mongoose.model("Dream", dreamSchema);