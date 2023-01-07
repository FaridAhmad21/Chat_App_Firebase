import 'package:chat_room_firebase/models/user_model.dart';
import 'package:chat_room_firebase/pages/complete_profile.dart';
import 'package:chat_room_firebase/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email == "" || password == "" || cPassword == ""){
      print("Please Fill all the fields");
    }else if(password != cPassword){
      print("Password do not Match");
    }else{
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async{
    UserCredential? credential;
    try{
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e){
      print(e.message.toString());
    }
     if(credential != null){
       String uid = credential.user!.uid;
       UserModel newUser = UserModel(
         uid: uid,
         email: email,
         fullname: "",
         profilepic: "",
       );
       await FirebaseFirestore.instance.collection("users").doc(uid).set
         (newUser.toMap()).then((value){
           print("New User Created");
           Navigator.push(
               context,
               MaterialPageRoute(
                   builder: (context){
                     return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!,);
                   }));
       }
       );
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Chat App", style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 45,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 10,),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: cPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                      ),
                    ),
                    SizedBox(height: 20,),

                    CupertinoButton(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Text("Sign Up"),
                        onPressed: (){
                          checkValues();
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context){
                          //           return CompleteProfile();
                          //         }));
                        }
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?",style: TextStyle(
                  fontSize: 16
              ),),
              CupertinoButton(
                  child: Text("Log In",style: TextStyle(
                      fontSize: 16
                  ),),
                  onPressed: (){
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
    );
  }
}
