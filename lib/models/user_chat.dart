import 'package:chat_app/constants/firestoreConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat{
  String id;
  String photoUrl;
  String nickname;
  String phoneNumber;
  String aboutMe;

  UserChat(
      {required this.id,required this.photoUrl,required this.nickname,required this.phoneNumber,required this.aboutMe});
  Map<String, String> toJson(){
    return{
      FireStoreConstants.nickname:nickname,
      FireStoreConstants.aboutMe:aboutMe,
      FireStoreConstants.photoUrl:photoUrl,
      FireStoreConstants.phoneNumber:phoneNumber
    };
  }
  factory UserChat.fromDocument(DocumentSnapshot doc){
    String photoUrl='';
    String nickname='';
    String phoneNumber='';
    String aboutMe='';
    try{
      photoUrl =doc.get(FireStoreConstants.photoUrl);
    }catch(e){

    } try{
      nickname =doc.get(FireStoreConstants.nickname);
    }catch(e){

    } try{
      aboutMe =doc.get(FireStoreConstants.aboutMe);
    }catch(e){

    } try{
      phoneNumber =doc.get(FireStoreConstants.phoneNumber);
    }catch(e){

    }
    return UserChat(id: doc.id, photoUrl: photoUrl,
        nickname: nickname, phoneNumber: phoneNumber, aboutMe: aboutMe);
  }
}