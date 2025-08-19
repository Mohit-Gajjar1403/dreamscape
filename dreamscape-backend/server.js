const express=require("express");
const cors=require("cors");

const app=express();
app.use(cors());
app.use(express.json());

app.post("/test",(req,res)=>{
    const {prompt}=req.body;
    res.json({message:`Hello Mohit! You said ${prompt}`});
});

app.listen(5000,()=>console.log("Server listening on 5000"));