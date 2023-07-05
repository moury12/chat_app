import 'dart:async';

import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/provides/AuthProvide.dart';
import 'package:chat_app/provides/homeProvider.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/screens/settings.dart';
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
  final GoogleSignIn googleSignIn =GoogleSignIn();
  final ScrollController scrollController =ScrollController();
  late String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  int _limit =20;
  int _limitIncrement =20;
  String _textSearch ='';
  List<PopupChoices> choices =<PopupChoices>[
    PopupChoices(title: "Sign Out", icon: Icons.logout),
    PopupChoices(title: "Settings", icon: Icons.settings),
  ];
  final TextEditingController searchBarTech = TextEditingController();
StreamController<bool> btnClearController =StreamController<bool>();

  @override
  void didChangeDependencies() {
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    if(authProvider.getUserFirebaseID()?.isNotEmpty==true){
      currentUserId =authProvider.getUserFirebaseID()!;
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen(),), (Route<dynamic>
          route) => false);
    }
    scrollController.addListener(scrollListener);
    super.didChangeDependencies();
  }
  Future<bool> onBackPress(){
    openDialog();
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: isWhite? Colors.white :
     Colors.black,

      appBar:AppBar (foregroundColor:isWhite? Colors.black54 :
      Colors.white54,
        leading:  Center(
        child: Stack(
          children: [
            Icon(Icons.chat_bubble,color: ColorConst.themeColor, size:50,),

            Positioned( left: 0, right: 0,top: 0,bottom: 10,
                child: Icon(Icons.emoji_emotions_outlined,color: Colors.deepPurple.shade900,size: 18,))
          ],
        ),
      ),
        elevation: 0,

      backgroundColor: isWhite? Colors.white :
      Colors.black,
        actions:<Widget> [
          IconButton(onPressed: (){}, icon: Switch(
            value: isWhite,onChanged:(value){
            setState(() {
              isWhite = value;
              print(isWhite);
            });
          },
            activeTrackColor: Colors.teal.shade100,
            activeColor:Colors.teal.shade50 ,
            inactiveTrackColor: Colors.teal.shade200,
            inactiveThumbColor: Colors.teal.shade900,
          )),
          builPopUpMenu(),
        ],
      ),
      body: WillPopScope(child: Stack(
        children: [
          Column(
            children: [
              buildSearchBar()
            ],
          )
        ],
      ), onWillPop: (){}),
    );
  }
Widget buildSearchBar(){

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      height: 40,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Icon(Icons.search,color: ColorConst.primaryColor,),
          SizedBox(width: 5,),
          Expanded(child: TextFormField(
            textInputAction: TextInputAction.search,
            controller: searchBarTech,
            onChanged: (v) {
              if(v.isNotEmpty){
                btnClearController.add(true);
                setState(() {
                  _textSearch=v;
                });
              }else{
                btnClearController.add(false);
                setState(() {
                  _textSearch='';
                });
              }
            },
            decoration: InputDecoration.collapsed(hintText: 'Search Here',
              hintStyle: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),
            ),

          )),
          StreamBuilder(stream: btnClearController.stream,
            builder: (context, snapshot) {
            return snapshot.data==true? GestureDetector(
              child: Icon(Icons.clear),
              onTap: (){
                searchBarTech.clear();
                btnClearController.add(false);
                setState(() {
                  _textSearch='';
                });
              }

            ):SizedBox.shrink();

          },)
      ],),

    );
}
@override
  void dispose() {
searchBarTech.dispose();    super.dispose();
  }
 Widget builPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      color:   isWhite? Colors.white :
      Colors.black,
      icon: Icon(Icons.menu, color: ColorConst.primaryColor,),
      onSelected: onItemMenuPress,
      itemBuilder: (context) {
      return choices.map((PopupChoices choice){
        return PopupMenuItem<PopupChoices>(

          value: choice,
            child: Row(children: [
              Icon(choice.icon,
              color: ColorConst.primaryColor,),SizedBox(width: 10,),
              Text(choice.title,style: TextStyle(color: isWhite? Colors.black54 :
              Colors.white54,),)
            ],));
      }).toList();
    },
    );
  }

  void onItemMenuPress(PopupChoices choice) {
    if(choice.title=="Sign Out"){
      handleSignOut();
    }else{
      Navigator.push(context,MaterialPageRoute(builder: (context) => SettingScreen(),) );

    }
  }

 Future <void> handleSignOut() async{
    authProvider.handleSignOut();
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginScreen(),) );

 }

  void scrollListener() {
    if(scrollController.offset>=scrollController.position.maxScrollExtent && !scrollController.position.outOfRange){
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Future<void> openDialog() async{}
}