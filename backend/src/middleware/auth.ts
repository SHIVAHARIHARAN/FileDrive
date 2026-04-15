import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export interface AuthRequest extends Request {
  userId?: string;
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      console.log("❌ No token provided");
      return res.status(401).json({
        success: false,
        message: "Access token required",
      });
    }

    const secret = process.env.JWT_SECRET || "your_secret_key";
    console.log("🔐 Verifying token with secret:", secret.substring(0, 10) + "...");

    jwt.verify(token, secret, (err: any, user: any) => {
      if (err) {
        console.log("❌ Token verification failed:", err.message);
        return res.status(403).json({
          success: false,
          message: "Invalid or expired token: " + err.message,
        });
      }

      console.log("✅ Token verified for user:", user.id);
      req.userId = user.id;
      next();
    });
  } catch (error) {
    console.log("❌ Auth error:", error);
    res.status(500).json({
      success: false,
      message: "Authentication error",
    });
  }
};
