import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/provides/AuthProvide.dart';
import 'package:chat_app/screens/home_page.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5),(){
      checkSignedIn();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
      Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Stack(
            children: [
              Icon(Icons.chat_bubble,color: ColorConst.themeColor, size: 180,),

              Positioned( left: 0, right: 0,top: 0,bottom: 25,
                  child: Icon(Icons.emoji_emotions_outlined,color: Colors.deepPurple.shade900,size: 60,))
            ],
          ),),
         // Text('Chat App',style: TextStyle(
            //color: ColorConst.textColor,fontSize: 20,fontWeight: FontWeight.bold
        //  ),),
          SizedBox(height: 10,),
          LoadingView()
        ],
      ),);
  }

  void checkSignedIn()async {
AuthProvider authProvider = context.read<AuthProvider>();
bool isLoggedIn = await authProvider.isLoggedIn();
if(isLoggedIn){
  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen(),) );
  return;
}
Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginScreen(),) );

  }
}
