import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(GitHubApp());
}

class GitHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Repositories',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GithubHomePage(),
    );
  }
}

class GithubHomePage extends StatefulWidget {
  @override
  _GithubHomePageState createState() => _GithubHomePageState();
}

class _GithubHomePageState extends State<GithubHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _repositories = [];
  String? _errorMessage;

  Future<void> fetchRepositories(String username) async {
    final url = 'https://api.github.com/users/$username/repos';
    try {
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        setState(() {
          _repositories = json.decode(response.body);
          _errorMessage = null;
        });
      }
      else {
        setState(() {
          _repositories = [];
          _errorMessage = 'Usuário não encontrado!';
        });
      }
    }
    catch (e) {
      setState(() {
        _repositories = [];
        _errorMessage = 'Erro ao buscar repositorios do usuario. Tente Novamente em alguns instantes!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Github Repositores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome de usuário do Github',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  fetchRepositories(_controller.text.trim());
                },
                child: Text('Buscar Repositórios')
            ),
            SizedBox(height: 16),
            if(_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            if(_repositories.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                    itemCount: _repositories.length,
                    itemBuilder: (context, index) {
                      final repo = _repositories[index];
                      return Card(
                        child: ListTile(
                          title: Text(repo['name']),
                          subtitle: Text(repo['description'] ?? 'Sem descrição'),
                          trailing:  Text('⭐ ${repo['stargazers_count']}'),
                        ),
                      );
                    },
                  )
              )
          ],
        ),
      ),
    );
  }
}



