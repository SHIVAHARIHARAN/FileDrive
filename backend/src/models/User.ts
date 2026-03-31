import {Schema , model} from "mongoose";

interface User{
    username:string;
    email:string;
    password:string;
    createdAt?:Date;
    updatedAt?:Date;
}

const userschema=new Schema<User>({
    username:{
        type:String,
        required:true,
    },
    email:{
        type:String,
        required:true,
        unique:true,
    },
    password:{
        type:String,
        required:true,
    }
},{timestamps:true}
);

export default model<User>("User",userschema);