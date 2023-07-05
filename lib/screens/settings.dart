import 'dart:io';

import 'package:chat_app/constants/app_constant.dart';
import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/models/user_chat.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/firestoreConstants.dart';
import '../main.dart';
import '../provides/settingsProvider.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String photoUrl = '';
  String id = '';
  String nickname = '';

  String phoneNumber = '';

  String aboutMe = '';

  TextEditingController? controllerNickname;

  TextEditingController? controllerabout;

  final TextEditingController controller = TextEditingController();
  String dialCodeDigits = "+00";
  bool isLoaded = false;

  File? avatarImage;

  late SettingsProvider settingsProvider;
  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeabout = FocusNode();
  @override
  void initState() {
    settingsProvider = context.read<SettingsProvider>();
    readLocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        foregroundColor: isWhite ? Colors.black54 : Colors.white70,
        title: Text(AppConst.SettingTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: getImage,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                    child: avatarImage == null
                        ? photoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.account_circle,
                                      color: ColorConst.primaryColor,
                                      size: 100,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.deepPurple,
                                      )),
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.account_circle,
                                color: ColorConst.primaryColor,
                                size: 100,
                              )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.file(
                              avatarImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ))),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: TextField(

                controller: controllerNickname,
                style: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),
                  hintText: 'Write Your Name',
                  hintStyle: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),

                ),
                onChanged: (v) {
                  nickname = v;
                },
                focusNode: focusNodeNickname,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: TextField(
                maxLines: 3,
                controller: controllerabout,
                onChanged: (v) {
                  aboutMe = v;
                },
                focusNode: focusNodeabout,
                style: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),

                  label: Text(
                    "About Me ",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isWhite ? Colors.white70: Colors.white70,),
                  ),
                ),
              ),
            ),
            Container( height: 60,
              width: 400,
              color: isWhite ? Colors.white70: Colors.white70,
              child: CountryCodePicker(
                //backgroundColor:  isWhite ? Colors.white70: Colors.white70,
                onChanged: (v){
                  setState(() {
                    dialCodeDigits =v.dialCode!;
                  });

                },
                initialSelection: "Bangladesh",
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: TextField(
                keyboardType: TextInputType.phone,
                controller: controller,
                onChanged: (v) {
                  phoneNumber = v;
                },
                style: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorConst.primaryColor)),
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: isWhite ? Colors.black54 : Colors.white70,),
                ),
              ),
            ),
            FloatingActionButton.extended(onPressed: handleUpdateData,
            backgroundColor: ColorConst.themeColor,
            label: Row(children: [
              Icon(Icons.update),Text('Update Now')
            ],),)
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
    File? img;
    if (pickedFile != null) {
      img = File(pickedFile.path);
    }
    if (img != null) {
      setState(() {
        avatarImage = img;
        isLoaded = true;
      });
      uploadFile();
    }
  }

  void readLocal() {
    setState(() {
      id = settingsProvider.getPref(FireStoreConstants.id) ?? '';
      nickname = settingsProvider.getPref(FireStoreConstants.nickname) ?? '';
      aboutMe = settingsProvider.getPref(FireStoreConstants.aboutMe) ?? '';
      photoUrl = settingsProvider.getPref(FireStoreConstants.photoUrl) ?? '';
      phoneNumber =
          settingsProvider.getPref(FireStoreConstants.phoneNumber) ?? '';
    });
    controllerNickname = TextEditingController(text: nickname);
    controllerabout = TextEditingController(text: aboutMe);
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeabout.unfocus();
    setState(() {
      isLoaded = true;
      if (dialCodeDigits != "+00" && controller.text != '') {
        phoneNumber = dialCodeDigits + controller.text.toString();
      }
    });
    UserChat userChat = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickname,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe);
    settingsProvider
        .updateDataFireStore(
            FireStoreConstants.pathUserCollection, id, userChat.toJson())
        .then((value) async {
      await settingsProvider.setPref(FireStoreConstants.nickname, nickname);
      await settingsProvider.setPref(FireStoreConstants.aboutMe, aboutMe);
      await settingsProvider.setPref(FireStoreConstants.photoUrl, photoUrl);
      await settingsProvider.setPref(
          FireStoreConstants.phoneNumber, phoneNumber);
      setState(() {
        isLoaded = false;
      });
      Fluttertoast.showToast(msg: "update success");
    }).catchError((e) {
      setState(() {
        isLoaded = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  void uploadFile() async {
    String filename = id;
    UploadTask uploadTask = settingsProvider.uploadTask(avatarImage!, filename);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat userChat = UserChat(
          id: id,
          photoUrl: photoUrl,
          nickname: nickname,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe);
      settingsProvider
          .updateDataFireStore(
              FireStoreConstants.pathUserCollection, id, userChat.toJson())
          .then((value) async {
        await settingsProvider.setPref(FireStoreConstants.photoUrl, photoUrl);
      });
    } catch (e) {
      setState(() {
        isLoaded = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
