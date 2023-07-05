import 'package:chat_app/constants/color_constants.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Center(
        child: CircularProgressIndicator(
          color: ColorConst.themeColor,
        ),
      ),
    );
  }
}
