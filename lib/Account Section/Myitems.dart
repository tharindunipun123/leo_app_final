import 'package:flutter/material.dart';

class MyItemsPage extends StatefulWidget {
  @override
  _MyItemsPageState createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  String? selectedFrame;
  String? selectedEffect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('My Items'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Section for Frames
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Choose a Frame',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      frameOption('Frame 1', Colors.red),
                      frameOption('Frame 2', Colors.blue),
                      frameOption('Frame 3', Colors.green),
                      defaultOption('No Frame'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Section for Entry Effects
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Choose an Entry Effect',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      effectOption('Fade In', Icons.opacity),
                      effectOption('Slide In', Icons.arrow_forward),
                      effectOption('Zoom In', Icons.zoom_in),
                      defaultOption('No Effect'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Display Selected Frame and Effect
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Frame: ${selectedFrame ?? "None"}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Selected Effect: ${selectedEffect ?? "None"}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget frameOption(String name, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFrame = name;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget effectOption(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEffect = name;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget defaultOption(String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (name == 'No Frame') {
            selectedFrame = null;
          } else if (name == 'No Effect') {
            selectedEffect = null;
          }
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
