import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_stream_io/chat_data.dart';
import 'package:intl/intl.dart';
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
            builder: (mainContext, widget) {
              return StreamChat(
                child: widget,
                client: ChatData.getInstance.client,
              );
            },
            home: Builder(
              builder: (BuildContext context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xFFe973a7),
                  title: Text('Candy land',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                body: ChannelsBloc(
                  child: SafeArea(
                    child: ChannelListView(
                      padding: EdgeInsets.only(top: 10),
                      sort: [SortOption('last_message_at')],
                      pagination: PaginationParams(
                        limit: 30,
                      ),
                      channelPreviewBuilder:
                          (BuildContext anotherContext, Channel channel) =>
                              _getCustomTileView(context, channel),
                      // _getDefaultTileView(context, channel),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  GestureDetector _getCustomTileView(BuildContext context, Channel channel) {
    int unreadCount = channel.state.unreadCount;

    return GestureDetector(
      onTap: () async {
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.only(bottom: 8, left: 4, right: 4),
        height: 80,
        decoration: BoxDecoration(
            color: unreadCount > 0 ? null : Color(0xFFf0f0f0),
            gradient: unreadCount > 0
                ? LinearGradient(
                    begin: Alignment.bottomLeft,
                    stops: [0.1, 0.9],
                    colors: [Color(0xFFa686e7), Color(0xFFe973a7)])
                : null,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            ChannelImage(
              channel: channel,
              borderRadius: BorderRadius.circular(12),
              constraints: BoxConstraints.tightFor(
                height: 48,
                width: 48,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChannelName(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: unreadCount > 0 ? Colors.white : Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  _getSubtitle(channel, unreadCount)
                ],
              ),
            ),
            SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                getTime(channel, unreadCount),
                getUnreadCount(unreadCount)
              ],
            )
          ],
        ),
      ),
    );
  }

  ChannelPreview _getDefaultTileView(BuildContext context, Channel channel) {
    return ChannelPreview(
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
    );
  }

  Widget _getSubtitle(Channel channel, int unreadCount) {
    final Message lastMessage = channel.state.messages.reversed
        .firstWhere((message) => !message.isDeleted);

    return Text(
      lastMessage.text ?? '',
      maxLines: 1,
      style: TextStyle(
          color: unreadCount > 0 ? Color(0xFFcbb7e6) : Color(0xFFa4a4b2),
          fontWeight: FontWeight.bold),
    );
  }

  Widget getTime(Channel channel, int unreadCount) {
    DateTime time = channel.lastMessageAt;
    return Text(
      time != null ? DateFormat('EEEE HH:mm').format(time) : '',
      style: TextStyle(
          color: unreadCount > 0 ? Color(0xFFcbb7e6) : Color(0xFFa4a4b2)),
    );
  }

  Widget getUnreadCount(int count) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        '$count',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      decoration: new BoxDecoration(
        color: Color(0xFFdf7df0),
        shape: BoxShape.circle,
      ),
    );
  }
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
