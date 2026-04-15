import dotenv from "dotenv";
import path from "path";

// Load .env FIRST, before any other imports!
dotenv.config({ path: path.resolve(__dirname, "../.env") });
console.log("📂 Loading .env from:", path.resolve(__dirname, "../.env"));
console.log("🔑 JWT_SECRET loaded from env:", process.env.JWT_SECRET?.substring(0, 20) + "...");

import express from "express";
import authRoutes from "./routes/authroutes";
import folderRoutes from "./routes/folderroutes";
import fileRoutes from "./routes/fileroutes";
import connectDB from "./config/db";
import cors from "cors";

const app = express();

app.use(cors());
app.use(express.json());

// Serve uploaded files
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

app.use("/api/auth", authRoutes);
app.use("/api/folders", folderRoutes);
app.use("/api/files", fileRoutes);

app.get("/", (req, res) => {
  res.send("API running 🚀");
});

connectDB();

const PORT = Number(process.env.PORT) || 5000;

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});