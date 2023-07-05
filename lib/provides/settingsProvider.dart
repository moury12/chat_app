import 'dart:io';

import 'package:chat_app/constants/firestoreConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider{
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  final FirebaseStorage firebaseStorage;

  SettingsProvider({required this.firebaseFirestore,required this.prefs,required this.firebaseStorage});
  String? getPref(String key){
    return prefs.getString(key);
  }
  Future<bool> setPref(String key, String value) async{
    return await prefs.setString(key, value);
  }
  UploadTask uploadTask (File img, String filename){
    Reference reference =firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(img);
    return uploadTask;
  }
  Future<void> updateDataFireStore(String collectionPath ,String docPath , Map<String, dynamic> dataneededUpdate
      ){
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataneededUpdate);
  }
  Stream<QuerySnapshot>getStreamFireStore(String collectionPath, int limit, String? textSearch){
    if(textSearch?.isNotEmpty==true){
      return firebaseFirestore.collection(collectionPath).limit(limit).where(FireStoreConstants.nickname, isEqualTo: textSearch).snapshots();
    }
    else{
      return firebaseFirestore.collection(collectionPath).limit(limit).snapshots();
    }
  }
}