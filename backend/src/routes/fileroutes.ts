import express from "express";
import { uploadFile, getFiles, deleteFile, renameFile } from "../controllers/fileController";
import upload from "../config/multer";
import { authenticateToken } from "../middleware/auth";

const router = express.Router();

// All file routes require authentication
router.post("/", authenticateToken, upload.single("file"), uploadFile);
router.get("/", authenticateToken, getFiles);
router.delete("/:id", authenticateToken, deleteFile);
router.put("/:id/rename", authenticateToken, renameFile);

export default router;
