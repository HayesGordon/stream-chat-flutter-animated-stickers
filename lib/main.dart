import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_rive/rive_stream_reactions.dart';
import 'package:stream_rive/users_page.dart';

void main() {
  final client = StreamChatClient(
    'YOUR-API-KEY', // TODO: insert your Stream app token here.
    logLevel: Level.INFO,
  );
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => StreamChat(
        // Modify the theme to display custom reactions.
        streamChatThemeData: StreamChatThemeData(
          reactionIcons: riveStreamReactionAnimations
              .map(
                (reaction) => ReactionIcon(
                  type: reaction.type,
                  builder: (context, highlighted, size) {
                    return KeyedSubtree(
                      key: ValueKey('reaction-${reaction.type}'),
                      child: RiveAnimation.asset(
                        'assets/stream_reactions.riv',
                        artboard: highlighted
                            ? reaction.artboardHighlighted
                            : reaction.artboard,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
        client: client,
        child: child,
      ),
      home: const UsersPage(),
    );
  }
}
