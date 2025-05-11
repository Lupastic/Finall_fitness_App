import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<User> _usersFromAPI = [];
  String? _error;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUsersFromAPI();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('name') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
    _savedName = prefs.getString('name');

    final file = await _getLocalFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      try {
        final jsonData = jsonDecode(contents);
        final user = User.fromJson(jsonData);
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _savedName = user.name;
        });
      } catch (e) {
        // Если JSON испорчен, ничего не делаем
      }
    }
  }


  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text;
    final email = _emailController.text;

    await prefs.setString('name', name);
    await prefs.setString('email', email);

    setState(() {
      _savedName = name;
    });

    // Save to local JSON file
    final user = User(id: 1, name: name, email: email);
    final jsonString = jsonEncode(user.toJson());
    final file = await _getLocalFile();
    await file.writeAsString(jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User data saved locally')),
    );
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/user_data.json');
  }

  Future<void> _fetchUsersFromAPI() async {
    try {
      final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        final users = usersJson.map((e) => User.fromJson(e)).toList();

        setState(() {
          _usersFromAPI = users;
          _error = null;
        });
      } else {
        throw Exception('Failed to load users');
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
            const SizedBox(height: 10),
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
