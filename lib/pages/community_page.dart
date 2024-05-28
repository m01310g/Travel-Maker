import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmaker/firebase/post_data.dart';
import 'package:travelmaker/pages/post/my_page.dart';
import 'package:travelmaker/firebase/post_create.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _sortByLikes = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text('커뮤니티'),
            Text(
              _sortByLikes ? '좋아요 순' : '최신 순',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _sortByLikes = !_sortByLikes;
              });
            },
            icon: Icon(_sortByLikes ? Icons.favorite : Icons.access_time),
            color: _sortByLikes ? Colors.red : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy(_sortByLikes ? 'likesCount' : 'timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final post = Post.fromSnapshot(documents[index]);
                return _buildPostItem(post);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostCreatePage()), // 수정 필요
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDataPage(post: post),
              ),
            );
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('UserData').doc(post.authorId).get(),
                  builder: (context, authorSnapshot) {
                    if (authorSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (authorSnapshot.hasError) {
                      return const Text('Error');
                    }
                    var authorData = authorSnapshot.data!.data() as Map<String, dynamic>;
                    final authorNickname = authorData['nickname'] ?? 'Unknown';
                    final authorProfileImageUrl = authorData['profileImageUrl'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: authorProfileImageUrl.isNotEmpty
                                ? NetworkImage(authorProfileImageUrl)
                                : null,
                            child: authorProfileImageUrl.isEmpty
                                ? Icon(Icons.account_circle, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            authorNickname,
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            post.timestamp.toDate().toString().substring(0, 16),
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      if (post.imageUrls.isNotEmpty)
                        SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.network(post.imageUrls[index]),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        post.content.length > 30 ? '${post.content.substring(0, 30)}...' : post.content,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _toggleLike(post);
                            },
                            icon: Icon(
                              post.likes.contains(FirebaseAuth.instance.currentUser!.uid)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.likes.contains(FirebaseAuth.instance.currentUser!.uid)
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.comment),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(post.id)
                                .collection('comments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('Loading...');
                              }
                              if (!snapshot.hasData) {
                                return Text('0');
                              }
                              return Text('${snapshot.data!.docs.length}');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike(Post post) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> likes = List<String>.from(post.likes);
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }
    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likes': likes,
      'likesCount': likes.length,
    });
  }

  void _loadUserData() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('UserData').doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (userData.exists) {
        var data = userData.data() as Map<String, dynamic>;
        String profileImageUrl = data['profileImageUrl'] ?? '';
        String nickname = data['nickname'] ?? '';

        setState(() {
          user = UserModel(
            uid: FirebaseAuth.instance.currentUser!.uid,
            profileImageUrl: profileImageUrl,
            nickname: nickname,
          );
        });
      } else {
        print('해당 사용자의 데이터가 존재하지 않습니다.');
      }
    } catch (e){
      print('사용자 정보 불러오기 중 오류 발생: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {}); // 화면 갱신을 위해 빈 setState 호출
  }
}

class UserModel {
  final String uid;
  final String profileImageUrl;
  final String nickname;

  UserModel({
    required this.uid,
    required this.profileImageUrl,
    required this.nickname,
  });
}

