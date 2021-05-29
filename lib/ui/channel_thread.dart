
import 'package:flutter/material.dart';
import 'package:get_stream_io/utils/date_time_utils.dart';
import 'package:get_stream_io/main.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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
              messageBuilder: _buildCustomBubble,
            ),
          ),
          MessageInput(
            actionsLocation: ActionsLocation.left,
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
    final Message message = details.message;
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