
import 'package:chat_app/constants/firestoreConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageChat{

  String idFrom;
  String idTo;
  String timeStamp;
  String content;
  int type;


  MessageChat(
      {

        required this.idFrom,

        required  this.idTo,
        required  this.timeStamp,
        required this.content,
        required this.type});
  Map<String, dynamic> toJson() {
    return {

      FireStoreConstants.idFrom: idFrom,

      FireStoreConstants.idTo: idTo,
      FireStoreConstants.timestamp: timeStamp,
      FireStoreConstants.content: content,
      FireStoreConstants.type: type,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc){
    String idFrom= doc.get(FireStoreConstants.idFrom);

    String idTo= doc.get(FireStoreConstants.idTo);
    String timeStamp=doc.get(FireStoreConstants.timestamp) ;
    String content= doc.get(FireStoreConstants.content);
   int type= doc.get(FireStoreConstants.type);
   return MessageChat(idFrom: idFrom, idTo: idTo, timeStamp: timeStamp, content: content, type: type);
  }


}