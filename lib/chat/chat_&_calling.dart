import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePagePopMenu.dart';

// Global navigator key for handling call invitations
final navigatorKey = GlobalKey<NavigatorState>();

class ChatScreen1 extends StatefulWidget {
  const ChatScreen1({Key? key}) : super(key: key);

  @override
  ChatScreen1State createState() => ChatScreen1State();
}

class ChatScreen1State extends State<ChatScreen1> {
  @override
  void initState() {
    super.initState();
    _initializeZegoCloud();
    _fetchAndSetUserAvatar();
  }

  Future<void> _initializeZegoCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final userName = prefs.getString('firstName') ?? '';

      if (userId.isEmpty) return;

      // Set the navigator key for handling call invitations
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

      // Initialize the call service
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1382376685, // Your Zego Cloud AppID
        appSign: '0a9bce0b90584625b087d27e8e3c9a2a15ea28eb16119022da829f87c3763142', // Your Zego Cloud AppSign
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        config: ZegoCallInvitationConfig(
          canInvitingInCalling: true,
        ),
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            channelID: 'ZegoUIKit',
            channelName: 'Call Notifications',
            sound: 'call',
            icon: 'call',
          ),
        ),
        requireConfig: (ZegoCallInvitationData data) {
          // Configure call UI based on call type
          final config = data.type == ZegoCallInvitationType.videoCall
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

          // Additional call UI configurations
          config.audioVideoViewConfig
            ..useVideoViewAspectFill = true;

          return config;
        },
      );
    } catch (e) {
      print('Error initializing Zego Cloud: $e');
    }
  }

  Future<void> _fetchAndSetUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final userName = prefs.getString('firstName') ?? '';

      if (userId.isEmpty) return;

      final response = await http.get(
        Uri.parse('http://145.223.21.62:8090/api/collections/users/records/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final avatarUrl = data['avatar'] != null
            ? 'http://145.223.21.62:8090/api/files/${data['collectionId']}/${data['id']}/${data['avatar']}'
            : null;

        if (avatarUrl != null) {
          await ZIMKit().updateUserInfo(
            avatarUrl: avatarUrl,
            name: userName,
          );
        }
      }
    } catch (e) {
      print('Error fetching user avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Important for call handling
      home: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Conversations'),
            actions: const [HomePagePopupMenuButton()],
          ),
          body: ZIMKitConversationListView(
            onPressed: (context, conversation, defaultAction) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZIMKitMessageListPage(
                    conversationID: conversation.id,
                    conversationType: conversation.type,
                    appBarActions: conversation.type == ZIMConversationType.peer
                        ? [
                      // Video Call Button
                      ZegoSendCallInvitationButton(
                        isVideoCall: true,
                        resourceID: 'zego_data',
                        invitees: [
                          ZegoUIKitUser(
                            id: conversation.id,
                            name: conversation.name,
                          ),
                        ],
                      ),
                      // Voice Call Button
                      ZegoSendCallInvitationButton(
                        isVideoCall: false,
                        resourceID: 'zego_data',
                        invitees: [
                          ZegoUIKitUser(
                            id: conversation.id,
                            name: conversation.name,
                          ),
                        ],
                      ),
                    ]
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}