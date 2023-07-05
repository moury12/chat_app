import 'package:chat_app/constants/firestoreConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_chat.dart';
enum Status{
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}
class AuthProvider extends ChangeNotifier{
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  Status _status =Status.uninitialized;
  Status get status => _status;

  AuthProvider(
      {required this.googleSignIn,
        required this.firebaseAuth,
        required this.firebaseFirestore,
        required this.prefs});
  String? getUserFirebaseID(){
    return prefs.getString(FireStoreConstants.id);
  }
  Future<bool> isLoggedIn() async{
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn && prefs.getString(FireStoreConstants.id)?.isNotEmpty == true){
      return true;
    }else{
      return false;
    }
  }
  Future<bool> handleSignin() async{
    _status =Status.authenticating;
    notifyListeners();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
if(googleUser!=null){
  GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
final AuthCredential credential =GoogleAuthProvider.credential(
  accessToken:  googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
User?  firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
if(firebaseUser!=null){
  final QuerySnapshot result = await
  firebaseFirestore.collection(FireStoreConstants.pathUserCollection).
    where(FireStoreConstants.id, isEqualTo: firebaseUser.uid).get();
  final List<DocumentSnapshot> document = result.docs;
  if(document.length==0){
    firebaseFirestore.collection(FireStoreConstants.pathUserCollection).doc(firebaseUser.uid).set({
      FireStoreConstants.nickname : firebaseUser.displayName,
      FireStoreConstants.photoUrl : firebaseUser.photoURL,
      FireStoreConstants.phoneNumber : firebaseUser.phoneNumber,
      FireStoreConstants.chattingWith : null,
      FireStoreConstants.timestamp: DateTime.now().millisecondsSinceEpoch.toString()
    });
    User? currentUSer =firebaseUser;
    await prefs.setString(FireStoreConstants.id, currentUSer.uid);
    await prefs.setString(FireStoreConstants.nickname, currentUSer.displayName??"");
    await prefs.setString(FireStoreConstants.phoneNumber, currentUSer.phoneNumber??"");
    await prefs.setString(FireStoreConstants.photoUrl, currentUSer.photoURL??"");
  }else{
    DocumentSnapshot documentSnapshot=document[0];
    UserChat userChat =UserChat.fromDocument(documentSnapshot);
    await prefs.setString(FireStoreConstants.id, userChat.id);
    await prefs.setString(FireStoreConstants.nickname, userChat.nickname);
    await prefs.setString(FireStoreConstants.aboutMe, userChat.aboutMe);
    await prefs.setString(FireStoreConstants.phoneNumber, userChat.phoneNumber);
    await prefs.setString(FireStoreConstants.photoUrl, userChat.photoUrl);
  }
    _status =Status.authenticated;
  notifyListeners();
  return true;
}else{
  _status =Status.authenticateError;
  return false;


}

}
else{
  _status =Status.authenticateCanceled;
  return false;


}
}
Future<void> handleSignOut() async{
    _status =Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    await googleSignIn.disconnect();
}
}