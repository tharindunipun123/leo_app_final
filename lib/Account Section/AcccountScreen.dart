import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:leo_app_01/Account%20Section/ViewProfile.dart';
import 'package:leo_app_01/Account%20Section/profileUpdate.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final String baseUrl = 'http://145.223.21.62:8090';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? 'd1k9aih2t9t9wo3';

      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 50.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blue[400]!, Colors.blue[800]!],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildProfileCard(context),
              _buildFeatureCard(
                context,
                'Wallet',
                FontAwesomeIcons.wallet,
                    () => _navigateToWallet(context),
              ),
              _buildFeatureCard(
                context,
                'Level',
                FontAwesomeIcons.chartLine,
                    () => _navigateToLevel(context),
              ),
              _buildFeatureCard(
                context,
                'Nobel',
                FontAwesomeIcons.crown,
                    () => _navigateToNobel(context),
              ),
              _buildFeatureCard(
                context,
                'SVIP',
                FontAwesomeIcons.gem,
                    () => _navigateToSVIP(context),
              ),
              _buildFeatureCard(
                context,
                'Achievements',
                FontAwesomeIcons.trophy,
                    () => _navigateToAchievements(context),
              ),
              _buildFeatureCard(
                context,
                'Invite Friends',
                FontAwesomeIcons.userPlus,
                    () => _navigateToInviteFriends(context),
              ),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    if (isLoading) {
      return const Card(
        margin: EdgeInsets.all(8.0),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    String? avatarUrl;
    if (userData != null && userData!['avatar'] != null) {
      avatarUrl = '$baseUrl/api/files/${userData!['collectionId']}/${userData!['id']}/${userData!['avatar']}';
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Hero(
              tag: 'profileAvatar',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData?['firstname'] ?? 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['moto'] ?? 'No motto set',
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToViewProfile(context),
                  icon: const FaIcon(FontAwesomeIcons.eye, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _navigateToEditProfile(context),
                  icon: const FaIcon(FontAwesomeIcons.pen, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: FaIcon(icon, color: Colors.blue[700], size: 20),
        ),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        child: Text('Logout'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'd1k9aih2t9t9wo3';
    // Navigate to Edit Profile screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(userId: 'd1k9aih2t9t9wo3',)),
    );
  }

  void _navigateToViewProfile(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'd1k9aih2t9t9wo3';
    // Navigate to Edit Profile screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileViewScreen(userId: userId,)),
    );
  }

  void _navigateToWallet(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'd1k9aih2t9t9wo3';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletScreen(userId: userId,)),
    );
  }

  void _navigateToLevel(BuildContext context) {
    // Navigate to Level screen
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceholderScreen('Level')));
  }

  void _navigateToNobel(BuildContext context) {
    // Navigate to Nobel screen
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceholderScreen('Nobel')));
  }

  void _navigateToSVIP(BuildContext context) {
    // Navigate to SVIP screen
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceholderScreen('SVIP')));
  }

  void _navigateToAchievements(BuildContext context) {
    // Navigate to Achievements screen
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceholderScreen('Achievements')));
  }

  void _navigateToInviteFriends(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => InviteFriendsPage()),
    // );
  }

  void _handleLogout(BuildContext context) {
    // Handle logout logic here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                // Perform logout action
                Navigator.of(context).pop();
                // Navigate to login screen or clear user session
              },
            ),
          ],
        );
      },
    );
  }
}

// Placeholder screen for navigation
class PlaceholderScreen extends StatelessWidget {
  final String title;

  PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('This is the $title screen'),
      ),
    );
  }
}