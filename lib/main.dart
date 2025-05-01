import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDfp6TwuTBF6pzDitao4oVLtVY9jkDOD68",
        authDomain: "rickpedia-76aa3.firebaseapp.com",
        projectId: "rickpedia-76aa3",
        storageBucket: "rickpedia-76aa3.appspot.com", // Corrigido aqui
        messagingSenderId: "244441036026",
        appId: "1:244441036026:web:c94552dea5ce1384b60543",
        measurementId: "G-WMHBS525MF",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Usa o google-services.json normalmente
  }

  runApp(const RickpediaApp());
}

class RickpediaApp extends StatelessWidget {
  const RickpediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rickpedia',
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
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () => _signInAnonymously(context),
          child: const Text('Entrar no Rickpedia'),
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
  int currentPage = 1;
  bool loading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCharacters();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !isLoadingMore && hasMore) {
        fetchMoreCharacters();
      }
    });
  }

  Future<void> fetchCharacters() async {
    setState(() => loading = true);
    final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$currentPage'));
    final data = jsonDecode(response.body);
    setState(() {
      characters = data['results'];
      loading = false;
      currentPage++;
      hasMore = data['info']['next'] != null;
    });
  }

  Future<void> fetchMoreCharacters() async {
    setState(() => isLoadingMore = true);
    final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$currentPage'));
    final data = jsonDecode(response.body);
    setState(() {
      characters.addAll(data['results']);
      currentPage++;
      isLoadingMore = false;
      hasMore = data['info']['next'] != null;
    });
  }

  Widget characterCard(Map character) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(character['image']),
              radius: 50,
            ),
            const SizedBox(height: 10),
            Text(
              character['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            infoText("Status", character['status']),
            infoText("Species", character['species']),
            infoText("Gender", character['gender']),
            infoText("Origin", character['origin']['name']),
            infoText("Location", character['location']['name']),
          ],
        ),
      ),
    );
  }

  Widget infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: characters.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < characters.length) {
                  return characterCard(characters[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}