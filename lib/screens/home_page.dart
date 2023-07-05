import 'dart:async';
import 'dart:io';

import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/constants/firestoreConstants.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_chat.dart';
import 'package:chat_app/provides/AuthProvide.dart';
import 'package:chat_app/provides/homeProvider.dart';
import 'package:chat_app/screens/chatPage.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/screens/settings.dart';
import 'package:chat_app/widgets/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../models/PopupChoices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();
  late String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = '';
  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: "Sign Out", icon: Icons.logout),
    PopupChoices(title: "Settings", icon: Icons.settings),
  ];
  final TextEditingController searchBarTech = TextEditingController();
  StreamController<bool> btnClearController = StreamController<bool>();

  @override
  void didChangeDependencies() {
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    if (authProvider
        .getUserFirebaseID()
        ?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseID()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
              (Route<dynamic> route) => false);
    }
    scrollController.addListener(scrollListener);
    super.didChangeDependencies();
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Widget buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: Colors.black45),
      ),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: ColorConst.primaryColor,
          ),
          SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTech,
              onChanged: (v) {
                if (v.isNotEmpty) {
                  btnClearController.add(true);
                  setState(() {
                    _textSearch = v;
                  });
                } else {
                  btnClearController.add(false);
                  setState(() {
                    _textSearch = '';
                  });
                }
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Search Here',
                hintStyle: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          StreamBuilder(
            stream: btnClearController.stream,
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? GestureDetector(
                child: Icon(Icons.clear),
                onTap: () {
                  searchBarTech.clear();
                  btnClearController.add(false);
                  setState(() {
                    _textSearch = '';
                  });
                },
              )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchBarTech.dispose();
    super.dispose();
  }

  Widget builPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      color: isWhite ? Colors.white : Colors.black,
      icon: Icon(
        Icons.menu,
        color: ColorConst.primaryColor,
      ),
      onSelected: onItemMenuPress,
      itemBuilder: (context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: [
                  Icon(
                    choice.icon,
                    color: ColorConst.primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(
                      color: isWhite ? Colors.black54 : Colors.white54,
                    ),
                  )
                ],
              ));
        }).toList();
      },
    );
  }

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == "Sign Out") {
      handleSignOut();
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingScreen(),
          ));
    }
  }

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Future<void> openDialog() async {
    switch (await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: ColorConst.primaryColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app),
                    Text('Exit app'),
                    Text('Are you sure to exit app?')
                  ],
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Row(
                children: [
                  Container(
                    child: Icon(Icons.cancel),
                  ),
                  Text('Cancel')
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Row(
                children: [
                  Container(
                    child: Icon(Icons.check_circle),
                  ),
                  Text('Yes')
                ],
              ),
            )
          ],
        );
      },
    )) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Widget BuildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
        return Card(
          color: Colors.white70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: TextButton(
                child: Row(
                  children: [
                    Material(
                      child: userChat.photoUrl.isNotEmpty
                          ? Image.network(
                        userChat.photoUrl,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 70,
                            height: 70,
                            child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurple,
                                )),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            color: ColorConst.primaryColor,
                            size: 70,
                          );
                        },
                      )
                          : Icon(
                        Icons.account_circle,
                        color: ColorConst.primaryColor,
                        size: 70,
                      ),
                      borderRadius: BorderRadius.circular(90),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Flexible(
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(userChat.nickname,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                                ),
                              ),
                             Padding(
                               padding: const EdgeInsets.only(left: 12.0),
                               child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(userChat.aboutMe,style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold,fontSize: 15),),
                                  ),
                             ),

                            ],
                          ),
                        ))
                  ],
                ),
                onPressed: () {
                  if (Utils.isKeyboardShowing()) {
                    Utils.closeKeyboard(context);
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                            peerId: userChat.id,
                            peerAvatar: userChat.photoUrl,
                            peerNickname: userChat.nickname,
                          )));
                },
              ),
            ),
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        foregroundColor: isWhite ? Colors.black54 : Colors.white54,
        leading: Center(
          child: Stack(
            children: [
              Icon(
                Icons.chat_bubble,
                color: ColorConst.themeColor,
                size: 50,
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 10,
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.deepPurple.shade900,
                    size: 18,
                  ))
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: isWhite ? Colors.white : Colors.black,
        actions: <Widget>[
          IconButton(
              onPressed: () {},
              icon: Switch(
                value: isWhite,
                onChanged: (value) {
                  setState(() {
                    isWhite = value;
                    print(isWhite);
                  });
                },
                activeTrackColor: Colors.teal.shade100,
                activeColor: Colors.teal.shade50,
                inactiveTrackColor: Colors.teal.shade200,
                inactiveThumbColor: Colors.teal.shade900,
              )),
          builPopUpMenu(),
        ],
      ),
      body: WillPopScope(
          child: Column(
            children: [buildSearchBar(),
              Expanded(child: StreamBuilder<QuerySnapshot>(
                stream: homeProvider.getStreamFireStore(FireStoreConstants.pathUserCollection, _limit, _textSearch),
                builder: (context, snapshot)  {
                  if(snapshot.hasData){
                    if((snapshot.data?.docs.length??0)>0){
                      return ListView.builder(itemCount: snapshot.data?.docs.length,
                        controller: scrollController,
                        itemBuilder: (context, index) => BuildItem(context, snapshot.data?.docs[index]),);

                    }else{
                      return Center(
                        child: Text('No user found...'),
                      );
                    }
                  }else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ))
            ],
          ),
          onWillPop: onBackPress),
    );
  }
}