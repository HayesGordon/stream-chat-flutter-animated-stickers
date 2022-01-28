import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'channels_page.dart';

@immutable
class DemoUser {
  final String id;
  final String name;
  final String image;

  const DemoUser({required this.id, required this.name, required this.image});
}

/// Demo users for testing. The ids should match those of the users you
/// created on the Stream dashboard.
const demoUsers = [
  DemoUser(
    id: 'gordon-hayes',
    name: 'Gordon Hayes',
    image: 'https://avatars.githubusercontent.com/u/13705472?v=4',
  ),
  DemoUser(
    id: 'nash-ramdial',
    name: 'Nash Ramdial',
    image: 'https://avatars.githubusercontent.com/u/25674767?v=4',
  )
];

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = false;

  /// Method to connect a user.
  Future<void> _connectUser(DemoUser demoUser) async {
    setState(() {
      _isLoading = true;
    });

    final client = StreamChat.of(context).client;
    try {
      await client.connectUser(
        User(
          id: demoUser.id,
          name: demoUser.name,
          image: demoUser.image,
        ),
        client.devToken(demoUser.id).rawValue,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ChannelsPage()),
      );
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Text(
                    'Select a User',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ...demoUsers.map((u) => UserTile(
                              demoUser: u,
                              callback: _connectUser,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

typedef UserTileCallback = void Function(DemoUser user);

class UserTile extends StatelessWidget {
  const UserTile({
    Key? key,
    required this.demoUser,
    required this.callback,
  }) : super(key: key);

  final DemoUser demoUser;
  final UserTileCallback callback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: Image.network(demoUser.image).image,
      ),
      title: Text(demoUser.name),
      onTap: () => callback(demoUser),
    );
  }
}
