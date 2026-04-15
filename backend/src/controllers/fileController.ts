import { Request, Response } from 'express';
import File from '../models/File';
import path from 'path';

interface AuthRequest extends Request {
  userId?: string;
}

// Sanitize filename
const sanitizeFilename = (filename: string): string => {
  return filename
    .replace(/[^a-zA-Z0-9._-]/g, '_')
    .substring(0, 255);
};

export const uploadFile = async (req: AuthRequest, res: Response) => {
  try {
    const { folderId } = req.body;
    const file = req.file;
    const userId = req.userId;

    if (!file) {
      return res.status(400).json({
        success: false,
        message: "No file provided",
      });
    }

    // Validate file size (max 50MB)
    if (file.size > 50 * 1024 * 1024) {
      return res.status(400).json({
        success: false,
        message: "File size exceeds 50MB limit",
      });
    }

    const fileUrl = `/uploads/${file.filename}`;
    const originalName = sanitizeFilename(file.originalname);

    const newFile = await File.create({
      name: originalName,
      folderId,
      userId,
      fileUrl,
    });

    res.status(201).json({
      success: true,
      message: "File uploaded successfully",
      file: newFile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error uploading file",
    });
  }
};

export const getFiles = async (req: AuthRequest, res: Response) => {
  try {
    const { folderId } = req.query;
    const userId = req.userId;

    // Only fetch files belonging to the user
    const files = await File.find({ folderId, userId });
    res.json({
      success: true,
      files,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching files",
    });
  }
};

export const deleteFile = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    // Check file ownership
    const file = await File.findById(id);
    if (!file) {
      return res.status(404).json({
        success: false,
        message: "File not found",
      });
    }

    if (file.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized: Cannot delete this file",
      });
    }

    await File.findByIdAndDelete(id);
    res.json({
      success: true,
      message: "File deleted",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error deleting file",
    });
  }
};

export const renameFile = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { newName } = req.body;
    const userId = req.userId;

    if (!newName || newName.trim() === '') {
      return res.status(400).json({
        success: false,
        message: "New filename is required",
      });
    }

    // Check file ownership
    const file = await File.findById(id);
    if (!file) {
      return res.status(404).json({
        success: false,
        message: "File not found",
      });
    }

    if (file.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized: Cannot rename this file",
      });
    }

    const sanitizedName = sanitizeFilename(newName);

    const updatedFile = await File.findByIdAndUpdate(
      id,
      { name: sanitizedName },
      { new: true }
    );

    res.json({
      success: true,
      message: "File renamed successfully",
      file: updatedFile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error renaming file",
    });
  }
};
