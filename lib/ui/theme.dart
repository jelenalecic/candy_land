import 'package:flutter/material.dart' hide TextTheme;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

StreamChatThemeData generateTheme() {
  return StreamChatThemeData(
    textTheme: TextTheme.light(),
    messageInputTheme: MessageInputTheme(
        inputBackground: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        inputTextStyle: TextStyle(
          color: Color(0xff555555),
          fontSize: 16.0,
        ),
        inputDecoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xff777777),
          ),
        ),
        activeBorderGradient: LinearGradient(
            begin: Alignment.bottomLeft,
            colors: [Color(0xFFe973a7), Color(0xFFe973a7)]),
        idleBorderGradient: LinearGradient(
            begin: Alignment.bottomLeft,
            colors: [Color(0xffcccccc), Color(0xffcccccc)])),
    colorTheme: ColorTheme.light(
      //channel image loading background
      accentBlue: Color(0xFFe973a7),
    ),
  );
}
