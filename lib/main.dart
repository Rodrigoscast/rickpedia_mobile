
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RickpediaApp());
}

class RickpediaApp extends StatelessWidget {
  const RickpediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rickpedia Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _signInAnonymously(BuildContext context) async {
    await FirebaseAuth.instance.signInAnonymously();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rickpedia Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInAnonymously(context),
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}

class CharacterList extends StatefulWidget {
  const CharacterList({super.key});

  @override
  State<CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  List characters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character'));
    final data = jsonDecode(response.body);
    setState(() {
      characters = data['results'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return ListTile(
                leading: Image.network(character['image'], width: 50),
                title: Text(character['name']),
                subtitle: Text('${character['status']} - ${character['species']}'),
              );
            },
          ),
    );
  }
}
