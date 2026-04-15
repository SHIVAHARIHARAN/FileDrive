import mongoose , {Document , Schema , Types } from "mongoose";
export interface IFolder extends Document{
    name:string;
    userId:Types.ObjectId;
    parentFolderId?:Types.ObjectId;
    createdAt?:Date;
    updatedAt?:Date;
}      

const folderSchema=new Schema<IFolder>({
    name:{
        type:String,    
        required:true,
    },
    userId:{
        type:Schema.Types.ObjectId,
        ref:"User", 
        required:true,
    },
    parentFolderId:{
        type:Schema.Types.ObjectId,
        ref:"Folder",
        default:null,
    },
    
},{timestamps:true}
);

export default mongoose.model<IFolder>("Folder",folderSchema);
