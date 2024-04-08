import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Post> _posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('커뮤니티'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _posts[index].title,
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '작성자: ${_posts[index].author}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8.0),
                          Text(_posts[index].content),
                          const SizedBox(height: 8.0),
                          _posts[index].image != null
                              ? Image.file(_posts[index].image!)
                              : const SizedBox(), // 이미지가 있으면 표시
                          const SizedBox(height: 8.0),
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
            FloatingActionButton(
              onPressed: () {
                _createNewPost(context);
              },
              child: const Icon(Icons.add),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _createNewPost(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시글 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
                pickedImage != null
                    ? Image.file(
                  File(pickedImage.path),
                  height: 100,
                )
                    : const SizedBox(),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final newPost = Post(
                      title: titleController.text,
                      content: contentController.text,
                      author: 'Anonymous',
                      image: pickedImage != null ? File(pickedImage.path) : null,
                    );
                    setState(() {
                      _posts.add(newPost);
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('작성 완료'),
                ),
              ],
            ),
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

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

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
          title: const Text('게시글 상세'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    widget.post.title,
    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 16.0),
    Text(
    '작성자: ${widget.post.author}',
    style: const TextStyle(fontStyle: FontStyle.italic),
    ),
    const SizedBox(height: 16.0),
    Text(widget.post.content),
    const SizedBox(height: 16.0),
    widget.post.image != null
    ? Image.file(
    widget.post.image!,
    height: 200,
    width: MediaQuery.of(context).size.width,
    fit: BoxFit.cover,
    )
        : const SizedBox(), // 이미지가 있으면 표시
    const SizedBox(height: 16.0),
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
      const SizedBox(height: 16.0),
      const Text(
        '댓글',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8.0),
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
      const SizedBox(height: 16.0),
      TextField(
        controller: _commentController,
        decoration: const InputDecoration(
          labelText: '댓글 작성',
        ),
      ),
      const SizedBox(height: 8.0),
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
        child: const Text('댓글 작성'),
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

