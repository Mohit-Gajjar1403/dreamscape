import express from "express";
import { registerUser, loginUser,getUser } from "../controllers/authController.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
import authMiddleware from "../middleware/authMiddleware.js";

router.get("/profile", authMiddleware, getUser);

export default router;
