import 'package:flutter/material.dart';
import 'package:get_stream_io/utils/date_time_utils.dart';
import 'package:get_stream_io/ui/channel_thread.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ListOfChannels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChannelListView(
      padding: EdgeInsets.only(top: 10),
      sort: [SortOption('last_message_at')],
      pagination: PaginationParams(
        limit: 30,
      ),
      separatorBuilder: (_, __) => Container(
        height: 0,
      ),
      channelPreviewBuilder: (BuildContext anotherContext, Channel channel) =>
          _getCustomTileView(context, channel),
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
