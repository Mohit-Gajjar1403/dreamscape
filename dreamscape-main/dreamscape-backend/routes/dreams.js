import express from "express";
import { protect } from "../controllers/authController.js";
import { generateDream, getUserDreams, shareDream, getPublicDreams, likeDream, dislikeDream,searchUserDreams,searchPublicDreams,searchDreams,getSharedDreams} from "../controllers/dreamController.js";

const router = express.Router();

router.post("/generate", generateDream);
router.get("/", getUserDreams);
router.post("/share", shareDream);
router.get("/public", getPublicDreams);
router.post("/like", likeDream);
router.post("/dislike", dislikeDream);
router.get("/search", protect, searchUserDreams);
router.get("/public/search", searchPublicDreams);
router.get("/filter/search", searchDreams);
router.get("/sharedtome",getSharedDreams);

export default router;