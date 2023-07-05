import 'package:cloud_firestore/cloud_firestore.dart';

class HomeProvider{
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});
  Future<void> updateDataFireStore(String collectionPath ,String docPath , Map<String, dynamic> dataneededUpdate
      ){
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataneededUpdate);
  }
}