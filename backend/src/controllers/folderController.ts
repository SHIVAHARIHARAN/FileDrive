import {Request , Response } from 'express';
import Folder from '../models/Folder';

export const createFolder=async(req:Request,res:Response)=>{
  try{
    const{name,userId,parentFolderId}=req.body;
    const folder = await Folder.create({name,userId,parentFolderId:parentFolderId || null});
    res.status(201).json({
      success:true,
      message:"Folder created successfully",
      folder,
    });
  } catch (error) {
    res.status(500).json({
      success:false,
      message:"Error creating folder",
    });

  }
} 

export const getFolders =async(req:Request,res:Response)=>{
  try {
    const {userId, parentFolderId}=req.query;
    let query: any = {userId};
    
    if (parentFolderId) {
      query.parentFolderId = parentFolderId;
    } else {
      query.parentFolderId = null;
    }
    
    const folders=await Folder.find(query);
     res.json({
      success: true,
      folders,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching folders",
    });
  }
};

export const deleteFolder = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    await Folder.findByIdAndDelete(id);

    res.json({
      success: true,
      message: "Folder deleted",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error deleting folder",
    });
  }
};