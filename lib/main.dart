import 'package:flutter/material.dart';
import 'package:leo_app_01/StartScreen.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:flutter/cupertino.dart';
import 'chat/default_dialogs.dart';

void main() {
  // Initialize the ZEGOCLOUD SDK
  ZIMKit().init(
    appID: 1382376685, // Replace with your AppID
    appSign: '0a9bce0b90584625b087d27e8e3c9a2a15ea28eb16119022da829f87c3763142', // Replace with your AppSign
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZEGOCLOUD Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StartScreen(),
    );
  }
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _userNameController = TextEditingController();
//
//   void _login() {
//     String userId = _userIdController.text;
//     String userName = _userNameController.text;
//
//     ZIMKit().connectUser(id: userId, name: userName).then((_) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => const ZIMKitDemoHomePage()),
//       );
//     }).catchError((error) {
//       // Handle login error
//       print("Login failed: $error");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _userIdController,
//               decoration: InputDecoration(labelText: 'User ID'),
//             ),
//             TextField(
//               controller: _userNameController,
//               decoration: InputDecoration(labelText: 'User Name'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _login, child: const Text('Login')),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ZIMKitDemoHomePage extends StatelessWidget {
  const ZIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ZIMKitConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                );
              },
            ));
          },
        ),
      ),
    );
  }
}


class HomePagePopupMenuButton extends StatefulWidget {
  const HomePagePopupMenuButton({Key? key}) : super(key: key);

  @override
  State<HomePagePopupMenuButton> createState() =>
      _HomePagePopupMenuButtonState();
}

class _HomePagePopupMenuButtonState extends State<HomePagePopupMenuButton> {
  final userIDController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupUsersController = TextEditingController();
  final groupIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      position: PopupMenuPosition.under,
      icon: const Icon(CupertinoIcons.add_circled),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'New Chat',
            child: const ListTile(
              leading: Icon(CupertinoIcons.chat_bubble_2_fill),
              title: Text('New Chat', maxLines: 1),
            ),
            onTap: () => showDefaultNewPeerChatDialog(context),
          ),
          // PopupMenuItem(
          //   value: 'New Group',
          //   child: const ListTile(
          //     leading: Icon(CupertinoIcons.person_2_fill),
          //     title: Text('New Group', maxLines: 1),
          //   ),
          //   onTap: () => showDefaultNewGroupChatDialog(context),
          // ),
          // PopupMenuItem(
          //   value: 'Join Group',
          //   child: const ListTile(
          //       leading: Icon(Icons.group_add),
          //       title: Text('Join Group', maxLines: 1)),
          //   onTap: () => showDefaultJoinGroupDialog(context),
          // ),
          PopupMenuItem(
            value: 'Delete All',
            child: const ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete All', maxLines: 1)),
            onTap: () {
              ZIMKit().deleteAllConversation(
                isAlsoDeleteFromServer: true,
                isAlsoDeleteMessages: true,
              );
            },
          ),
        ];
      },
    );
  }
}
