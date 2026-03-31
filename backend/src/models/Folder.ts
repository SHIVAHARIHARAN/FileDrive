import mongoose , {Document , Schema , Types } from "mongoose";
export interface IFolder extends Document{
    name:string;
    userId:Types.ObjectId;
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
    }
},{timestamps:true}
);

export default mongoose.model<IFolder>("Folder",folderSchema);
