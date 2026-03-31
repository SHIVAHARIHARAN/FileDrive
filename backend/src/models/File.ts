import mongoose , {Document , Schema , Types } from "mongoose";

export interface IFile extends Document{
    name:string;
    folderId:Types.ObjectId;
    userId:Types.ObjectId;  
    fileUrl:string;
    createdAt?:Date;
    updatedAt?:Date;
}

const fileSchema = new Schema<IFile>({
    name:{
        type:String,
        required:true,
    },
    folderId:{
        type:Schema.Types.ObjectId,
        ref:"Folder",
        required:true,
    },
    userId:{
        type:Schema.Types.ObjectId,
        ref:"User",
        required:true,
    },
    fileUrl:{
        type:String,
        defa1ult:"",
    }
},{timestamps:true}
);

export default mongoose.model<IFile>("File",fileSchema);