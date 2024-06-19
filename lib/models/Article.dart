// ignore: file_names
import 'dart:convert';

import 'package:absensi/utils/api.dart';

class Article {
  final int id;
  final String date;
  final String link;
  final String title;
  final String thumbnail;


  const Article({
    required this.id,
    required this.date,
    required this.link,
    required this.title,
    required this.thumbnail,

  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        id: json['id'],
        date: json['date'],
        link: json['link'],
        title: json['title']['rendered'],
        thumbnail: json['yoast_head_json']['og_image'][0]['url'],
      );
  }
}

Future<List<Article>> fetchArticle() async {
  var res = await Network().fetchData('https://suemerugrup.com/wp-json/wp/v2/posts/');
  var jsonData = jsonDecode(res.body);
  if (res.statusCode == 200 && jsonData != null) {
    List<Article> articles = [];
    for (var i = 0; i < jsonData.length; i++) {
      articles.add(Article.fromJson(jsonData[i]));
    }
    return articles;
  } else {
    throw Exception('Failed to load article');
  }
}