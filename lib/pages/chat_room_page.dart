import 'dart:developer';

import 'package:chat_room_firebase/main.dart';
import 'package:chat_room_firebase/models/chat_room_model.dart';
import 'package:chat_room_firebase/models/message_model.dart';
import 'package:chat_room_firebase/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User fireBaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.fireBaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime?.now(),
        text: msg,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).set(widget.chatroom.toMap());
      log("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon", descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.active) {
                        if(snapshot.hasData) {
                          QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                          return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                            currentMessage.text.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                  ],
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("An Error Occured!"),
                          );
                        } else {
                          return Center(
                            child: Text("Say hi to your new friend"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                        child: TextField(
                      maxLines: null,
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Enter Message"),
                    )),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
