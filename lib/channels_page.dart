import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_rive/users_page.dart';

import 'channel_page.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  /// Method to disconnect the current user and navigate back to the [UsersPage].
  Future<void> _disconnect() async {
    await StreamChat.of(context).client.disconnectUser();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UsersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels Page'),
        actions: [
          TextButton(
            onPressed: _disconnect,
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ChannelsBloc(
        child: ChannelListView(
          filter: Filter.in_(
            'members',
            [StreamChat.of(context).currentUser!.id],
          ),
          sort: const [SortOption('last_message_at')],
          limit: 20,
          channelWidget: const ChannelPage(),
          emptyBuilder: (context) => const CreateChannelFromUsers(), // Add this
        ),
      ),
    );
  }
}

class CreateChannelFromUsers extends StatelessWidget {
  const CreateChannelFromUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UsersBloc(
      child: UserListView(
        filter: Filter.notIn('id', [StreamChat.of(context).currentUser!.id]),
        limit: 20,
        onUserTap: (user, widget) {
          StreamChat.of(context)
              .client
              .createChannel('messaging', channelData: {
            'members': [user.id, StreamChat.of(context).currentUser!.id]
          });
        },
      ),
    );
  }
}
