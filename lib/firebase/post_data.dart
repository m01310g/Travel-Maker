import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelmaker/pages/community_page.dart';
import '../pages/post/my_page.dart'; // 마이페이지 파일 임포트
import 'package:travelmaker/firebase/post_edit.dart'; // 데이터 편집 페이지 파일 임포트

class PostDataPage extends StatefulWidget {
  final Post post;

  const PostDataPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDataPageState createState() => _PostDataPageState();
}

class _PostDataPageState extends State<PostDataPage> {
  final TextEditingController _commentController = TextEditingController();
  late User _currentUser;
  bool _isLoading = false;
  late String? currentUserNickname;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _fetchUserNickname();
  }

  void _fetchUserNickname() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('UserData').doc(_currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUserNickname = userDoc['nickname'];
        });
      }
    } catch (e) {
      print('사용자 별명 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          if (widget.post.authorId == _currentUser.uid) // 작성자만 수정 및 삭제 버튼 표시
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataEditPage(documentId: widget.post.id),
                  ),
                );
              },
            ),
          if (widget.post.authorId == _currentUser.uid)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildPostDetails(userId),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text('이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _deletePost();
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).delete();
      // 삭제 성공 시 마이페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CommunityPage()), // 마이페이지로 이동
      );
    } catch (e) {
      print('게시글 삭제 오류: $e');
    }
  }

  Widget _buildPostDetails(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300,
          child: PageView(
            children: widget.post.imageUrls.map((imageUrl) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                )
                    : Placeholder(),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.post.content,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Divider(),
                _buildCommentsSection(),
                _buildAddCommentSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('아직 댓글이 없습니다.'));
        }

        final comments = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Comment(
            id: doc.id,
            content: data['content'] ?? '',
            authorId: data['authorId'] ?? '',
            authorNickname: data['authorNickname'] ?? '',
            timestamp: data['timestamp'] ?? Timestamp.now(),
          );
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final bool isMyComment = comment.authorId == _currentUser.uid;

            return ListTile(
              title: Text(comment.authorId == _currentUser.uid ? currentUserNickname ?? '알 수 없음' : comment.authorNickname),
              subtitle: Text(comment.content),
              trailing: isMyComment
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero, // 패딩 제거
                    icon: Icon(Icons.edit),
                    iconSize: 15,
                    onPressed: () {
                      _editComment(comment);
                    },
                  ),
                  SizedBox(width: 8), // 간격 조절
                  IconButton(
                    padding: EdgeInsets.zero, // 패딩 제거
                    icon: Icon(Icons.delete),
                    iconSize: 15,
                    onPressed: () {
                      _deleteComment(comment);
                    },
                  ),
                ],
              )
                  : null,
            );



          },
        );
      },
    );
  }

  Widget _buildAddCommentSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: '댓글 추가...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _currentUser.uid.isNotEmpty ? _addComment : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _addComment() async {
    final userId = _currentUser.uid;
    final content =    _commentController.text.trim();
    if (content.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        String authorNickname = currentUserNickname ?? '알 수 없음';

        final comment = Comment(
          id: FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').doc().id,
          content: content,
          authorId: userId,
          authorNickname: authorNickname,
          timestamp: Timestamp.now(),
        );

        await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').doc(comment.id).set(comment.toMap());

        _commentController.clear();
      } catch (e) {
        print('댓글 추가 오류: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('댓글 내용이 비어 있습니다.');
    }
  }

  Future<void> _editComment(Comment comment) async {
    final updatedContent = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('댓글 편집'),
        content: TextField(
          controller: TextEditingController()..text = comment.content,
          onChanged: (value) => comment.content = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, comment.content);
              _updateComment(comment);
            },
            child: Text('저장'),
          ),
        ],
      ),
    );

    if (updatedContent != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').doc(comment.id).update({
          'content': updatedContent,
        });
      } catch (e) {
        print('댓글 편집 오류: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('댓글 삭제'),
        content: Text('이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeComment(comment);
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeComment(Comment comment) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').doc(comment.id).delete();
    } catch (e) {
      print('댓글 삭제 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateComment(Comment comment) async {
    // 댓글 업데이트를 위한 구현이 여기에 들어갑니다.
  }
}

class Post {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> likes;
  final int likesCount;
  final Timestamp timestamp;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.likes,
    required this.likesCount,
    required this.timestamp,
    required this.comments,
  });

  factory Post.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Post(
      id: snapshot.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      authorId: data['authorId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      comments: [], // 처음에는 댓글이 비어 있습니다.
    );
  }
}

class Comment {
  final String id;
  String content;
  final String authorId;
  final String authorNickname;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorNickname,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'authorId': authorId,
      'authorNickname': authorNickname,
      'timestamp': timestamp,
    };
  }
}

