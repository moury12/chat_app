import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/provides/AuthProvide.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =Provider.of<AuthProvider>(context);
    switch(authProvider.status){
    case Status.authenticateError:
    Fluttertoast.showToast(msg: "Sign in Failed");
    break;
    case Status.authenticateCanceled:
    Fluttertoast.showToast(msg: "Sign in Cancel");
    break;
    case Status.authenticated:
    Fluttertoast.showToast(msg: "Sign in SuccessFully");
    break;
      default:
    break;
    }
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          Expanded(flex: 1,
            child: Center(
              child: Container( decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: ColorConst.btnColor,
              ),
                child: TextButton.icon(onPressed: ()async{
                  bool isSuccess = await authProvider.handleSignin();
                  if(isSuccess){
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen(),) );

                  }
                }, icon:  Image.network(
                    'http://pngimg.com/uploads/google/google_PNG19635.png',
                    fit:BoxFit.cover,height: 50,width: 50,
                )        , label: Text('Sign In  '
                    ,style: TextStyle(
                      color: ColorConst.textColor,fontSize: 40,fontWeight: FontWeight.bold
                        ),
                )),
              ),
            ),
          ),
      ],),
    );
  }
}