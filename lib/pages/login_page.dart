import 'package:chat_room_firebase/models/user_model.dart';
import 'package:chat_room_firebase/pages/homepage.dart';
import 'package:chat_room_firebase/pages/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == ""){
      print("Please Fill all the fields");
    }else{
      logIn(email, password);
    }
  }

  void logIn(String email, String password)async{
    UserCredential? credential;
    try{
      credential = await FirebaseAuth.instance.
      signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e){
      print(e.message.toString());
    }
    if(credential != null){
      String uid = credential.user!.uid;
      DocumentSnapshot? userData = await FirebaseFirestore.instance.
      collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);

      print("Log In Successfully!");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context){
                return HomePage(userModel: userModel, fireBaseUser: credential!.user!);
              }));
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
                  SizedBox(height: 20,),

                  CupertinoButton(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text("Login"),
                      onPressed: (){
                        checkValues();
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
            Text("Don't have an account?",style: TextStyle(
              fontSize: 16
            ),),
            CupertinoButton(
                child: Text("Sign Up",
                  style: TextStyle(
                  fontSize: 16
                ),),
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context){
                            return SignUpPage();
                          }));
                })
          ],
        ),
      )
    );
  }
}
