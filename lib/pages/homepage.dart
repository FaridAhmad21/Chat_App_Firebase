import 'package:chat_room_firebase/models/user_model.dart';
import 'package:chat_room_firebase/pages/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User fireBaseUser;

  const HomePage({super.key, required this.userModel, required this.fireBaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
      ),
      body: SafeArea(
        child: Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context){
                    return SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.fireBaseUser);
                  }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
