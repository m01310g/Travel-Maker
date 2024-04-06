import 'dart:io';
import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              '작성자: ${widget.post.author}',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16.0),
            widget.post.image != null
                ? Image.file(
              widget.post.image!,
              height: 200,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            )
                : SizedBox(), // 이미지가 있으면 표시
            SizedBox(height: 16.0),
            Text(widget.post.content),
            SizedBox(height: 16.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.liked ? Icons.favorite : Icons.favorite_border,
                    color: widget.post.liked ? Colors.red : null,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.post.liked ? '좋아요 취소' : '좋아요'),
                      ),
                    );
                    setState(() {
                      if (widget.post.liked) {
                        widget.post.likeCount--;
                      } else {
                        widget.post.likeCount++;
                      }
                      widget.post.liked = !widget.post.liked;
                    });
                  },
                ),
                Text('${widget.post.likeCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String content;
  final String author;
  int likeCount;
  bool liked;
  File? image;

  Post({
    required this.title,
    required this.content,
    required this.author,
    this.likeCount = 0,
    this.liked = false,
    this.image,
  });
}

class PostButton extends StatelessWidget {
  final Post post;

  const PostButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: post),
          ),
        );
      },
      child: Text(post.title),
    );
  }
}
