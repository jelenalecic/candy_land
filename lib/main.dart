import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TextTheme;
import 'package:get_stream_io/data/chat_data.dart';
import 'package:get_stream_io/ui/theme.dart';
import 'package:get_stream_io/ui/list_of_channels.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final String customFontFamily = 'Kaushan';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ChatData.getInstance.initialize(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return !ChatData.getInstance.isInitialized
        ? Container(
            color: Colors.white,
            child: Center(
                child: CupertinoActivityIndicator(animating: true, radius: 20)))
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (_, widget) {
              return StreamChat(
                streamChatThemeData: generateTheme(),
                child: widget,
                client: ChatData.getInstance.client,
              );
            },
            home: Builder(
              builder: (BuildContext context) => Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Color(0xFFe973a7),
                  title: Text('Candy land',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: customFontFamily,
                          letterSpacing: 2,
                          fontSize: 28)),
                ),
                body: ChannelsBloc(
                  child: SafeArea(
                    child: ListOfChannels(),
                  ),
                ),
              ),
            ),
          );
  }
}
