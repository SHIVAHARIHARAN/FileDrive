import express from "express";
import { createFolder , getFolders , deleteFolder} from '../controllers/folderController';

const router=express.Router();
router.post('/', createFolder);
router.get("/", getFolders);
router.delete("/:id", deleteFolder);
export default router;