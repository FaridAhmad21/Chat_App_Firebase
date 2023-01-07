import 'package:chat_room_firebase/models/user_model.dart';
import 'package:chat_room_firebase/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source)async {
    XFile? pickedFile =  await ImagePicker().pickImage(source: source);

    if (pickedFile!= null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20
    );

    if(croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path) ;
      });
    }
  }

  void showPhotoOption(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text("Select From Gallery"),
                  onTap: (){
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a Photo"),
                  onTap: (){
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        });
  }

  void checkValues(){
    String fullName = fullNameController.text.trim();

    if(fullName == "" || imageFile == null){
      print("Please Fill all the fields");
    }else{
      uploadData();
    }
  }

  void uploadData()async{
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepicture").
    child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;
    
    await FirebaseFirestore.instance.collection("users").doc(
      widget.userModel.uid).set(widget.userModel.toMap()).then((value) {
        print("Data Uploaded to Firebase");
        Navigator.push(
            context, 
            MaterialPageRoute(
                builder: (context){
                  return HomePage(userModel: widget.userModel, fireBaseUser: widget.firebaseUser);
                }));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(height: 20,),
              CupertinoButton(
                padding: EdgeInsets.all(0),
                onPressed: (){
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (imageFile != null) ? FileImage(imageFile!) :
                  null,
                  child: (imageFile == null) ? Icon(Icons.person,size: 60,) :
                  null,
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name"
                ),
              ),
              SizedBox(height: 20,),
              CupertinoButton(
                  color: Theme.of(context).colorScheme.secondary,

                  child: Text("Submit",
                  ),
                  onPressed: (){
                    checkValues();
                    // Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
