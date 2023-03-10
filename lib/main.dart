import 'package:chat_room_firebase/models/firebase_helper.dart';
import 'package:chat_room_firebase/models/user_model.dart';
import 'package:chat_room_firebase/pages/complete_profile.dart';
import 'package:chat_room_firebase/pages/homepage.dart';
import 'package:chat_room_firebase/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null){
    UserModel? thisUserModel = await FirebaseHelper.
    getUserModelById(currentUser.uid);
    if(thisUserModel != null){
      runApp(MyAppLoggedIn(userModel: thisUserModel,
          firebaseUser: currentUser));
    }else{
      runApp(MyApp());
    }
  }else{
    runApp(MyApp());
  }
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {

  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, fireBaseUser: firebaseUser),
    );
  }
}

