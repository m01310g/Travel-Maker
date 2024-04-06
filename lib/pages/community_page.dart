import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Post> _posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('커뮤니티'),
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(post: _posts[index]),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _posts[index].title,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '작성자: ${_posts[index].author}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 8.0),
                    Text(_posts[index].content),
                    SizedBox(height: 8.0),
                    _posts[index].image != null
                        ? Image.file(_posts[index].image!)
                        : SizedBox(), // 이미지가 있으면 표시
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _posts[index].liked ? Icons.favorite : Icons.favorite_border,
                            color: _posts[index].liked ? Colors.red : null,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_posts[index].liked) {
                                _posts[index].likeCount--;
                              } else {
                                _posts[index].likeCount++;
                              }
                              _posts[index].liked = !_posts[index].liked;
                            });
                          },
                        ),
                        Text('${_posts[index].likeCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createNewPost(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewPost(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();

    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('게시글 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                ),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              pickedImage != null
                  ? Image.file(
                File(pickedImage.path),
                height: 100,
              )
                  : SizedBox(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final newPost = Post(
                    title: _titleController.text,
                    content: _contentController.text,
                    author: 'Anonymous',
                    image: pickedImage != null ? File(pickedImage.path) : null,
                  );
                  setState(() {
                    _posts.add(newPost);
                  });
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('작성 완료'),
              ),
            ],
          ),
        );
      },
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
  List<Comment> comments;

  Post({
    required this.title,
    required this.content,
    required this.author,
    this.likeCount = 0,
    this.liked = false,
    this.image,
    this.comments = const [],
  });
}

class Comment {
  final String text;

  Comment({
    required this.text,
  });
}

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

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
            Text(widget.post.content),
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
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.liked ? Icons.favorite : Icons.favorite_border,
                    color: widget.post.liked ? Colors.red : null,
                  ),
                  onPressed: () {
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
            SizedBox(height: 16.0),
            Text(
              '댓글',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  return ListTile(
                    title: Text(comment.text),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: '댓글 작성',
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.post.comments.add(
                    Comment(
                      text: _commentController.text,
                    ),
                  );
                  _commentController.clear(); // 댓글 작성 후 입력 필드 비우기
                  print('댓글 추가됨: ${widget.post.comments}');
                });
              },
              child: Text('댓글 작성'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}


class PostDetailPageState extends State<PostDetailPage> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

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
    widget.post.title
    ,style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      SizedBox(height: 16.0),
      Text(
        '작성자: ${widget.post.author}',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      SizedBox(height: 16.0),
      Text(widget.post.content),
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
      Row(
        children: [
          IconButton(
            icon: Icon(
              widget.post.liked ? Icons.favorite : Icons.favorite_border,
              color: widget.post.liked ? Colors.red : null,
            ),
            onPressed: () {
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
      SizedBox(height: 16.0),
      Text(
        '댓글',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      Expanded(
        child: ListView.builder(
          itemCount: widget.post.comments.length,
          itemBuilder: (context, index) {
            final comment = widget.post.comments[index];
            return ListTile(
              title: Text(comment.text),
            );
          },
        ),
      ),
      SizedBox(height: 16.0),
      TextField(
        controller: _commentController,
        decoration: InputDecoration(
          labelText: '댓글 작성',
        ),
      ),
      SizedBox(height: 8.0),
      ElevatedButton(
        onPressed: () {
          setState(() {
            widget.post.comments.add(
              Comment(
                text: _commentController.text,
              ),
            );
            _commentController.clear(); // 댓글 작성 후 입력 필드 비우기
            print('댓글 추가됨: ${widget.post.comments}');
          });

        },
        child: Text('댓글 작성'),
      ),


    ],
    ),
    ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
