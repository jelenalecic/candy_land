import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TextTheme;
import 'package:get_stream_io/chat_data.dart';
import 'package:get_stream_io/date_time_utils.dart';
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
            builder: (mainContext, widget) {
              return StreamChat(
                streamChatThemeData: StreamChatThemeData(
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
                          colors: [Color(0xffcccccc),Color(0xffcccccc)])),
                  colorTheme: ColorTheme.light(
                    //channel image loading background
                    accentBlue: Color(0xFFe973a7),
                  ),
                ),
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
                    child: ChannelListView(
                      padding: EdgeInsets.only(top: 10),
                      sort: [SortOption('last_message_at')],
                      pagination: PaginationParams(
                        limit: 30,
                      ),
                      separatorBuilder: (_, __) => Container(
                        height: 0,
                      ),
                      channelPreviewBuilder:
                          (BuildContext anotherContext, Channel channel) =>
                              _getCustomTileView(context, channel),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _getCustomTileView(BuildContext context, Channel channel) {
    return StreamBuilder<int>(
      stream: channel.state?.unreadCountStream,
      initialData: channel.state?.unreadCount,
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StreamChannel(
                    channel: channel,
                    child: ChannelThread(),
                  );
                },
              ),
            );
          },
          child: AnimatedCrossFade(
            crossFadeState: snapshot.data > 0
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 500),
            firstChild: _getChannelItem(snapshot, channel, true),
            secondChild: _getChannelItem(snapshot, channel, false),
          ),
        );
      },
    );
  }

  Container _getChannelItem(
      AsyncSnapshot<int> snapshot, Channel channel, bool hasUnread) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.only(bottom: 10, left: 8, right: 8),
      height: 80,
      decoration: BoxDecoration(
          color: hasUnread ? null : Color(0xFFffffff),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFa686e7).withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
          gradient: hasUnread
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
                      color: hasUnread ? Colors.white : Colors.black),
                ),
                SizedBox(
                  height: 4,
                ),
                _getSubtitle(channel, snapshot.data)
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              getTime(channel, snapshot.data),
              getUnreadCount(snapshot.data)
            ],
          )
        ],
      ),
    );
  }

  Widget _getSubtitle(Channel channel, int unreadCount) {
    String lastMsgString = '';

    if (channel.state.messages.length > 0) {
      final Message lastMessage = channel.state.messages.reversed
          .firstWhere((message) => !message.isDeleted);
      lastMsgString = lastMessage.text ?? '';
    }

    return Text(
      lastMsgString,
      maxLines: 1,
      style: TextStyle(
          color: unreadCount > 0 ? Color(0xFFcbb7e6) : Color(0xFFa4a4b2),
          fontWeight: FontWeight.bold),
    );
  }

  Widget getTime(Channel channel, int unreadCount) {
    DateTime time = channel.lastMessageAt;
    return Text(
      time != null ? parseDateTime((time)) : '',
      style: TextStyle(
        color: unreadCount > 0 ? Color(0xFFcbb7e6) : Color(0xFFa4a4b2),
        fontSize: 12,
      ),
    );
  }

  Widget getUnreadCount(int count) {
    return count > 0
        ? Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            height: 40,
            child: Text(
              '$count',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            decoration: new BoxDecoration(
              color: Color(0xFFdf7df0),
              shape: BoxShape.circle,
            ),
          )
        : SizedBox(
            height: 40,
          );
  }
}

class ChannelThread extends StatelessWidget {
  const ChannelThread({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa686e7),
        title: ChannelName(
          textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: customFontFamily,
              letterSpacing: 2,
              fontSize: 24),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF222222).withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ChannelImage(
              borderRadius: BorderRadius.circular(24),
              constraints: BoxConstraints.tightFor(width: 44),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              dateDividerBuilder: (DateTime dateTime) => Container(
                alignment: Alignment.center,
                child: Text(
                  parseDayOnly(dateTime),
                  style: TextStyle(
                      color: Color(0xff999999),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: customFontFamily),
                ),
              ),
              threadBuilder: (_, parentMessage) {
                return ThreadPage(
                  parent: parentMessage,
                );
              },
              messageBuilder: _buildCustomBubble,
            ),
          ),
          MessageInput(
            disableAttachments: true,
            activeSendButton: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.send_rounded,
                size: 32,
                color: Color(0xFFe973a7),
              ),
            ),
            idleSendButton: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.send_rounded,
                size: 32,
                color: Color(0xFFbbbbbb),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBubble(
    BuildContext context,
    MessageDetails details,
    List<Message> messages,
  ) {
    final message = details.message;
    final isCurrentUser = StreamChat.of(context).user.id == message.user.id;
    final crossAxisAlignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final mainAxisAlignment =
        isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    List<Widget> rowItems = [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF999999).withOpacity(0.6),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: UserAvatar(
          user: message.user,
        ),
      ),
      Flexible(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                color: isCurrentUser ? null : Color(0xfff5f5f5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight:
                        isCurrentUser ? Radius.zero : Radius.circular(10),
                    bottomLeft:
                        isCurrentUser ? Radius.circular(10) : Radius.zero),
                gradient: isCurrentUser
                    ? LinearGradient(
                        begin: Alignment.bottomLeft,
                        stops: [0.1, 0.9],
                        colors: [Color(0xFFa686e7), Color(0xFFe973a7)])
                    : null),
            child: message.attachments.isNotEmpty &&
                    message.attachments[0].type == 'giphy'
                ? SizedBox(
                    child: GiphyAttachment(
                        message: message,
                        attachment: message.attachments[0],
                        size: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          MediaQuery.of(context).size.height * 0.3,
                        )),
                  )
                : Text(
                    message.text ?? '',
                    style: TextStyle(
                        color: isCurrentUser ? Colors.white : Color(0xff707070),
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
          ),
        ),
      ),
    ];

    if (isCurrentUser) {
      rowItems = rowItems.reversed.toList();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            mainAxisAlignment: mainAxisAlignment,
            children: rowItems,
          ),
          Container(
            margin: EdgeInsets.only(left: 40, right: 40, top: 2),
            child: Text(
              parseTimeOnly(message.createdAt),
              style: TextStyle(
                  color: Color(0xffbbbbbb),
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  final Message parent;

  ThreadPage({
    Key key,
    this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
          ),
          MessageInput(
            parentMessage: parent,
          ),
        ],
      ),
    );
  }
}
