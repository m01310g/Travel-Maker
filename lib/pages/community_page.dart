import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

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
              physics: const NeverScrollableScrollPhysics(),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _posts[index].images.isNotEmpty
                              ? Image.file(
                            _posts[index].images[0],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                              : const SizedBox(width: 100),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _posts[index].title,
                                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  // 기존의 Text 위젯을 ExpandableText 위젯으로 대체
                                  ExpandableText(
                                    text: _posts[index].content,
                                    maxHeight: 100.0, // 최대 허용 높이를 설정하세요. 이 예제에서는 100.0으로 설정했습니다.
                                  ),
                                  const SizedBox(height: 8.0),
                                  // 아래의 Text 위젯은 제거하거나, 필요에 따라 유지합니다.
                                  // Text(_posts[index].content),
                                  // const SizedBox(height: 8.0),
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

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createNewPost(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewPost(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    // 여러 이미지를 선택
    List<XFile>? pickedImages = await picker.pickMultiImage();

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
                if (pickedImages.isNotEmpty)
                  ...pickedImages.map((image) {
                    return Image.file(
                      File(image.path),
                      height: 100,
                    );
                  }),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final newPost = Post(
                      title: titleController.text,
                      content: contentController.text,
                      author: 'Anonymous',
                      images: pickedImages != null ? pickedImages.map((image) => File(image.path)).toList() : [],
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

class ExpandableText extends StatefulWidget {
  final String text;
  final double maxHeight;

  const ExpandableText({super.key, required this.text, this.maxHeight = 100.0});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String firstHalf;
  late String secondHalf;

  bool hiddenText = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 100) {
      firstHalf = widget.text.substring(0, 100);
      secondHalf = widget.text.substring(100, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final span = TextSpan(text: firstHalf + (hiddenText ? "..." : secondHalf));
        final tp = TextPainter(text: span, maxLines: hiddenText ? null : 3, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: size.maxWidth);

        if (tp.size.height <= widget.maxHeight) {
          return Text(widget.text);
        } else {
          return Column(
            children: [
              RichText(
                text: TextSpan(
                  text: hiddenText ? ("$firstHalf...") : (firstHalf + secondHalf),
                  style: DefaultTextStyle.of(context).style,
                ),
                maxLines: hiddenText ? 3 : null,
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(hiddenText ? "더 보기" : "접기", style: const TextStyle(color: Colors.blue)),
                  ],
                ),
                onTap: () {
                  setState(() {
                    hiddenText = !hiddenText;
                  });
                },
              ),
            ],
          );
        }
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
  List<File> images; // 이미지 리스트를 추가
  List<Comment> comments;

  Post({
    required this.title,
    required this.content,
    required this.author,
    this.likeCount = 0,
    this.liked = false,
    required this.images,
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

  const PostDetailPage({super.key, required this.post});

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 여러 이미지를 표시
              if (widget.post.images.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.post.images.map((image) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(
                          image,
                          height: 340,
                          width: 340,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16.0),
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
              SingleChildScrollView(
                child: Column(
                  children: widget.post.comments.map((comment) {
                    return ListTile(
                      title: Text(comment.text),
                    );
                  }).toList(),
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
                  });
                },
                child: const Text('댓글 작성'),
              ),
            ],
          ),
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

