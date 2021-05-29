import 'package:stream_chat_flutter/stream_chat_flutter.dart';

const String apiKey = 'dt6qyrp9u87z';

//token generator https://getstream.io/chat/docs/react/token_generator/?q=generate%20User%20token

final ChatUser user1 = ChatUser(
    'JayDee',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiSmF5RGVlIn0.zCCv8yzo5NClk96-1PCpZ40wQ3FCinGpsrq5eHTBcgs',
    'https://trekbaron.com/wp-content/uploads/2020/06/types-of-beaches-June302020-1-min.jpg');
final ChatUser user2 = ChatUser(
    'Clone',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiQ2xvbmUifQ.KUZxmRjaxi79uSKLdiuoZm7jOCiEMpkdkySaf4UkHZQ',
    'https://paul4innovating.files.wordpress.com/2014/01/tropical-rainforest-1.png');

final ChatUser currentUser = user1;

class ChatData {
  static ChatData _instance;

  StreamChatClient client;
  List<ChannelWrapper> channelWrappers;

  ChatData._();

  static ChatData get getInstance => _instance ??= ChatData._();

  void initialize(Function onInitialized) async {
    StreamChatClient client = StreamChatClient(
      apiKey,
      logLevel: Level.INFO,
    );

    client
        .connectUser(
            User(id: currentUser.id, extraData: {
              'image': currentUser.imageUrl,
            }),
            currentUser.token)
        .then((Event value) async {
      this.client = client;
      createChannels();
      // await updateChannels();
      await watchChannels();
      onInitialized();
    });
  }

  Future<void> updateChannels() async {
    await channelWrappers[0].channel.updatePartial({
      "set": {
        "image":
            "https://flutter.dev/assets/dash/early-dash-sketches5-c0dd280e07268980b30abbe372c73d3bceff18c7fdcde96f14b4240f6b6ee4ce.jpg"
      }
    });
    await channelWrappers[1].channel.updatePartial({
      "set": {
        "image": "https://sc04.alicdn.com/kf/HTB1y49dnXkoBKNjSZFEq6zrEVXaX.jpg"
      }
    });
    await channelWrappers[2].channel.updatePartial({
      "set": {
        "image": "https://trekbaron.com/wp-content/uploads/2020/06/types-of-beaches-June302020-1-min.jpg"
      }
    });
  }

  void createChannels() {
    channelWrappers = [
      ChannelWrapper(
          client.channel(
            'messaging',
            id: 'flutterdevs',
            extraData: {'name': 'Flutter devs'},
          ),
          false),
      ChannelWrapper(
          client.channel(
            'messaging',
            id: 'fun',
            extraData: {
              'name': 'Fun',
            },
          ),
          false),
      ChannelWrapper(
          client.channel(
            'messaging',
            id: 'beach_time',
            extraData: {
              'name': 'Beach time',
            },
          ),
          false)
    ];
  }

  Future<void> watchChannels() async {
    for (int i = 0; i < channelWrappers.length; i++) {
      await channelWrappers[i].channel.watch();
      channelWrappers[i].initialized = true;
    }

    return;
  }

  bool get isInitialized => this.client != null && areChannelsInitialized();

  bool areChannelsInitialized() {
    bool areInitialized = true;

    for (int i = 0; i < channelWrappers.length; i++) {
      if (!channelWrappers[i].initialized) {
        areInitialized = false;
        break;
      }
    }

    return areInitialized;
  }
}

class ChannelWrapper {
  ChannelWrapper(this.channel, this.initialized);
  Channel channel;
  bool initialized;
}

class ChatUser {
  ChatUser(this.id, this.token, this.imageUrl);
  String id;
  String token;
  String imageUrl;
}
