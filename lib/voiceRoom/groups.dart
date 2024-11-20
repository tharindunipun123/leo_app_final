import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'live_page.dart';
import 'voiceRoomCreate.dart';

// Model class for Voice Room remains the same
class VoiceRoom {
  final String id;
  final String voiceRoomName;
  final int voiceRoomId;
  final String ownerId;
  final String voiceRoomCountry;
  final String teamMoto;
  final String groupPhoto;
  final String tags;
  final String backgroundImages;

  VoiceRoom({
    required this.id,
    required this.voiceRoomName,
    required this.voiceRoomId,
    required this.ownerId,
    required this.voiceRoomCountry,
    required this.teamMoto,
    required this.groupPhoto,
    required this.tags,
    required this.backgroundImages,
  });

  factory VoiceRoom.fromJson(Map<String, dynamic> json) {
    return VoiceRoom(
      id: json['id'],
      voiceRoomName: json['voice_room_name'],
      voiceRoomId: json['voiceRoom_id'],
      ownerId: json['ownerId'],
      voiceRoomCountry: json['voiceRoom_country'],
      teamMoto: json['team_moto'],
      groupPhoto: json['group_photo'],
      tags: json['tags'],
      backgroundImages: json['background_images'],
    );
  }
}

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Mine", "Hot"];
  List<VoiceRoom> _voiceRooms = [];
  String? _userId;
  String? _username;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUserData();
    _fetchVoiceRooms();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _username = prefs.getString('firstName');
    });
  }

  Future<void> _fetchVoiceRooms() async {
    try {
      final response = await http.get(
        Uri.parse('http://145.223.21.62:8090/api/collections/voiceRooms/records'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        setState(() {
          _voiceRooms = items.map((item) => VoiceRoom.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching voice rooms: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreateRoom() {
    // TODO: Implement navigation to create room page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVoiceRoomPage(), // Replace with your CreateRoomPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildAdvertBanner(),

            TabBar(
              controller: _tabController,
              tabs: _tabs.map((String name) => Tab(text: name)).toList(),
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue[700],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVoiceRoomsList(true),
                  _buildVoiceRoomsList(false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateRoom,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.lightBlue[50],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search voice rooms...',
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildAdvertBanner() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/800/200'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget _buildRankingSection() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRankingCategory(String title) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            3,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage('https://picsum.photos/50/50?random=$index'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceRoomsList(bool isMineTab) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    final filteredRooms = isMineTab
        ? _voiceRooms.where((room) => room.ownerId == _userId).toList()
        : _voiceRooms;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) => _buildRoomCard(filteredRooms[index]),
    );
  }

  Widget _buildRoomCard(VoiceRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToLivePage(room),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: 'http://145.223.21.62:8090/api/files/voiceRooms/${room.id}/${room.groupPhoto}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(color: Colors.blue)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.voiceRoomName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text('ID: ${room.voiceRoomId}',overflow: TextOverflow.ellipsis,),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(room.voiceRoomCountry),
                      const Spacer(),
                      _buildTags(room.tags),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.teamMoto,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(String tags) {
    final tagsList = tags.split(',');
    return Row(
      children: tagsList.map((tag) =>
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag.trim(),
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ),
      ).toList(),
    );
  }

  void _navigateToLivePage(VoiceRoom room) {
    final isHost = room.ownerId == _userId;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivePage(
          roomID: room.id,
          isHost: isHost,
          username1: _username ?? '',
          userId: _userId!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}