import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateVoiceRoomPage extends StatefulWidget {
  @override
  _CreateVoiceRoomPageState createState() => _CreateVoiceRoomPageState();
}

class _CreateVoiceRoomPageState extends State<CreateVoiceRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? voiceRoomName;
  String? voiceRoomId;
  String? voiceRoomCountry;
  String? teamMoto;
  String? tags;
  File? groupPhoto;
  File? backgroundImage;
  bool isLoading = false;

  Future<void> _pickImage(bool isGroupPhoto) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isGroupPhoto) {
          groupPhoto = File(image.path);
        } else {
          backgroundImage = File(image.path);
        }
      });
    }
  }

  bool isValid10DigitNumber(String? input) {
    if (input == null) return false;
    return RegExp(r'^\d{10}$').hasMatch(input);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      _formKey.currentState!.save();

      var uri = Uri.parse('http://109.199.99.84:8090/api/collections/voiceRooms/records');
      var request = http.MultipartRequest('POST', uri);

      request.fields['voice_room_name'] = voiceRoomName ?? '';
      request.fields['voiceRoom_id'] = voiceRoomId ?? '';
      request.fields['voiceRoom_country'] = voiceRoomCountry ?? '';
      request.fields['team_moto'] = teamMoto ?? '';
      request.fields['tags'] = tags ?? '';

      if (groupPhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'group_photo',
          groupPhoto!.path,
        ));
      }

      if (backgroundImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'background_images',
          backgroundImage!.path,
        ));
      }

      try {
        final response = await request.send();
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice room created successfully!')),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to create voice room');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating voice room: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Voice Room'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Card(
            child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Voice Room Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'This field is required' : null,
                  onSaved: (value) => voiceRoomName = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Voice Room ID (10 digits)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    helperText: 'Enter a 10-digit number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'This field is required';
                    }
                    if (!isValid10DigitNumber(value)) {
                      return 'Please enter exactly 10 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => voiceRoomId = value,
                  maxLength: 10,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  onSaved: (value) => voiceRoomCountry = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Team Motto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_quote),
                  ),
                  onSaved: (value) => teamMoto = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  onSaved: (value) => tags = value,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  children: [
                  ElevatedButton.icon(
                  onPressed: () => _pickImage(true),
          icon: Icon(Icons.photo_camera),
          label: Text('Select Group Photo'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        if (groupPhoto != null)
    Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Image.file(groupPhoto!, height: 100),
    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(false),
                      icon: Icon(Icons.wallpaper),
                      label: Text('Select Background Image'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    if (backgroundImage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Image.file(backgroundImage!, height: 100),
                      ),
                  ],
              ),
          ),
        ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Create Voice Room',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
    );
  }
}