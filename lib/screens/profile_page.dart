import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _savedName;
  List<User> _usersFromAPI = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUsersFromAPI();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('name');
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    setState(() {
      _savedName = _nameController.text;
    });

    User user = User(id: 1, name: _nameController.text, email: _emailController.text);
    String jsonString = jsonEncode(user.toJson());
    User restoredUser = User.fromJson(jsonDecode(jsonString));
    print('Serialized JSON: $jsonString');
    print('Deserialized User: ${restoredUser.name}, ${restoredUser.email}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User data saved')),
    );
  }

  Future<void> _fetchUsersFromAPI() async {
    try {
      final response = await http.get(Uri.parse('https://reqres.in/api/users'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final users = jsonData.map((e) => User.fromJson(e)).toList();
        setState(() {
          _usersFromAPI = users;
        });
      } else {
        throw Exception('API error');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading users: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_savedName != null)
              Text('Welcome back, $_savedName!',
                  style: const TextStyle(fontSize: 18)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Save'),
            ),
            const Divider(height: 40),
            const Text('Users from API', style: TextStyle(fontSize: 18)),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ..._usersFromAPI.map((user) => ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            )),
          ],
        ),
      ),
    );
  }
}