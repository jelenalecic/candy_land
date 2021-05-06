import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_stream_io/chat_data.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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
            theme: ThemeData(fontFamily: 'RobotoMono'),
            builder: (context, widget) {
              return StreamChat(
                child: widget,
                client: ChatData.getInstance.client,
              );
            },
            home: Builder(
              builder: (BuildContext context) => Scaffold(
                body: ChannelsBloc(
                  child: ChannelListView(
                    sort: [SortOption('last_message_at')],
                    pagination: PaginationParams(
                      limit: 30,
                    ),
                    channelPreviewBuilder:
                        (BuildContext anotherContext, Channel channel) =>
                            ChannelPreview(
                      channel: channel,
                      onTap: (channel) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return StreamChannel(
                                channel: channel,
                                child: ChannelPage(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

Widget channelPreviewBuilder(BuildContext context, Channel channel) {
  final lastMessage = channel.state.messages.reversed
      .firstWhere((message) => !message.isDeleted);

  final subtitle = (lastMessage == null ? "nothing yet" : lastMessage.text);
  final opacity = channel.state.unreadCount > .0 ? 1.0 : 0.5;

  return ListTile(
    leading: ChannelImage(
      channel: channel,
    ),
    title: ChannelName(
      // channel: channel,
      textStyle: StreamChatTheme.of(context).channelPreviewTheme.title.copyWith(
            color: Colors.black.withOpacity(opacity),
          ),
    ),
    subtitle: Text(subtitle),
    trailing: channel.state.unreadCount > 0
        ? CircleAvatar(
            radius: 10,
            child: Text(channel.state.unreadCount.toString()),
          )
        : SizedBox(),
  );
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}
