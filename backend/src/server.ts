import dotenv from "dotenv";
dotenv.config();
import connectDB from "./config/db";
console.log("Server is running...");
connectDB();