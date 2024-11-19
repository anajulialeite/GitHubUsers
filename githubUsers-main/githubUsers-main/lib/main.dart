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
      title: 'GitHub Repositories',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Modificando a cor principal do tema para teal
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
      if (response.statusCode == 200) {
        setState(() {
          _repositories = json.decode(response.body);
          _errorMessage = null;
        });
      } else {
        setState(() {
          _repositories = [];
          _errorMessage = 'Usuário não encontrado!';
        });
      }
    } catch (e) {
      setState(() {
        _repositories = [];
        _errorMessage = 'Erro ao buscar repositórios do usuário. Tente novamente!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GitHub Repositories',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para digitar o nome do usuário
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome de usuário do GitHub',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.teal),
                labelStyle: TextStyle(fontSize: 18, color: Colors.teal),
              ),
            ),
            SizedBox(height: 16),
            
            // Botão para buscar os repositórios
            ElevatedButton(
              onPressed: () {
                fetchRepositories(_controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal, // Cor de fundo
                onPrimary: Colors.white, // Cor do texto
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Buscar Repositórios'),
            ),
            SizedBox(height: 16),
            
            // Exibindo a mensagem de erro (caso ocorra)
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            SizedBox(height: 16),
            
            // Exibindo os repositórios encontrados
            if (_repositories.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _repositories.length,
                  itemBuilder: (context, index) {
                    final repo = _repositories[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(repo['owner']['avatar_url']),
                        ),
                        title: Text(
                          repo['name'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${repo['description'] ?? 'Sem descrição'}\nLinguagem: ${repo['language'] ?? 'Indefinida'}',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          '⭐ ${repo['stargazers_count']}',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Caso não haja repositórios, exibe uma mensagem
            if (_repositories.isEmpty && _errorMessage == null)
              Text(
                'Nenhum repositório encontrado. Tente um nome de usuário diferente.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
