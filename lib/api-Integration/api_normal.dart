import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//------- Model -----------*/
class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(id: json['id'], title: json['title'], body: json['body']);
  }
}

//-------  Api Service -----------*/
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));
    if (response.statusCode == 200) {
      log(name: 'ApiService', 'https://jsonplaceholder.typicode.com/posts');
      final List data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

//------- Ui -----------*/
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  PostListScreenState createState() => PostListScreenState();
}

class PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = ApiService().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts')),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts found.'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.body),
                );
              },
            );
          }
        },
      ),
    );
  }
}
