import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestoreConstants.dart';

class HomeProvider{
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});
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