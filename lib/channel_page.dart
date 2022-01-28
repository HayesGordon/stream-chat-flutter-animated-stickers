import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Scaffold(
      appBar: const ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              messageBuilder: (context, details, messages, defaultMessage) {
                final attachments = details.message.attachments;
                if (attachments.isNotEmpty &&
                    attachments[0].type == 'sticker') {
                  return defaultMessage.copyWith(
                    messageTheme:
                        StreamChatTheme.of(context).ownMessageTheme.copyWith(
                              messageBackgroundColor: Colors.transparent,
                              messageBorderColor: Colors.transparent,
                            ),
                    customAttachmentBuilders: {
                      'sticker': (context, message, attachments) {
                        return SizedBox(
                          height: 130,
                          width: 130,
                          child: AnimatedSticker(
                            artboard:
                                attachments[0].extraData['artboard'] as String,
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return defaultMessage;
                }
              },
            ),
          ),
          MessageInput(
            actions: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.smiley,
                  color: Colors.grey,
                ),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints.tightFor(
                  height: 24,
                  width: 24,
                ),
                splashRadius: 24,
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) =>
                        StickersGrid(channel: channel),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class StickersGrid extends StatefulWidget {
  const StickersGrid({
    Key? key,
    required this.channel,
  }) : super(key: key);

  final Channel channel;

  @override
  _StickersGridState createState() => _StickersGridState();
}

class _StickersGridState extends State<StickersGrid> {
  static late Future<RiveFile> riveFile = loadRiveFile();

  static Future<RiveFile> loadRiveFile() async {
    return await RiveFile.asset('assets/rive_stickers.riv');
  }

  Future<void> sendSticker(String artboardName) async {
    await widget.channel.sendMessage(
      Message(
        attachments: [
          Attachment(
            uploadState: const UploadState.success(),
            type: 'sticker',
            extraData: {
              'artboard': artboardName,
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
            child: Text(
              'Stickers',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Artboard>>(
              future: riveFile.then((value) => value.artboards),
              builder: (context, snapshot) {
                final artboards = snapshot.data ?? [];
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Loading....');
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (artboards.isEmpty) {
                        return const Center(child: Text('No stickers'));
                      }
                      return Scrollbar(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: artboards.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              sendSticker(snapshot.data![index].name);
                            },
                            child: AnimatedSticker(
                              artboard: artboards[index].name,
                            ),
                          ),
                        ),
                      );
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSticker extends StatelessWidget {
  const AnimatedSticker({
    Key? key,
    required this.artboard,
  }) : super(key: key);

  final String artboard;

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/rive_stickers.riv',
      artboard: artboard,
      animations: const ['idle'],
    );
  }
}
