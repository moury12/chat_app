import 'package:chat_app/provides/AuthProvide.dart';
import 'package:chat_app/provides/homeProvider.dart';
import 'package:chat_app/provides/settingsProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_constant.dart';
import 'screens/splash_page.dart';
bool isWhite =true;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp( MyApp(prefs: prefs,));
}

class MyApp extends StatelessWidget {
final SharedPreferences prefs;
final FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
   MyApp({required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider(
            googleSignIn: GoogleSignIn(),
            firebaseAuth: FirebaseAuth.instance, firebaseFirestore: this.firebaseFirestore, prefs: this.prefs)
          ,) ,
        Provider<SettingsProvider>(create: (context) => SettingsProvider(firebaseStorage: this.firebaseStorage,
             firebaseFirestore: this.firebaseFirestore, prefs: this.prefs)
          ,),
        Provider<HomeProvider>(create: (context) => HomeProvider(
             firebaseFirestore: this.firebaseFirestore)
          ,),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConst.appTitle,
        theme: ThemeData(

          primarySwatch: Colors.lightGreen,
        ),
        home: SplashScreen()
      ),
    );
  }
}
