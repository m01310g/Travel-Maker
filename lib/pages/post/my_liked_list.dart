import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../map_page.dart';
import '../route_page.dart';

class MyLikedList extends StatefulWidget {
  const MyLikedList({Key? key}) : super(key: key);

  @override
  _MyLikedListState createState() => _MyLikedListState();
}

class _MyLikedListState extends State<MyLikedList> {
  List<dynamic> likedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("찜한 장소"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('UserData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null || userData['likedItems'] == null) {
            return const Center(child: Text("찜한 여행이 없습니다."));
          }

          likedItems = List<dynamic>.from(userData['likedItems']);

          return Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    // 경로 확인을 위한 출발지, 목적지 및 경유지 초기화
                    LatLng? startLocation; // 출발지
                    LatLng? destinationLocation; // 목적지
                    List<LatLng> waypoints = []; // 경유지 목록
                    List<String> waypointTitles = []; // 장소 제목 목록

                    // Firestore에서 현재 사용자의 데이터 가져오기
                    var userData = await FirebaseFirestore.instance
                        .collection('UserData')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get();

                    // 사용자 데이터에서 찜한 장소 목록 가져오기
                    List<dynamic> likedItems = userData.data()?['likedItems'] ?? [];

                    // 만약 찜한 장소가 없다면 리턴
                    if (likedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('찜한 장소가 없습니다.')),
                      );
                      return;
                    }

                    // 첫 번째 찜한 장소를 출발지로 설정
                    startLocation = LatLng(likedItems[0]['mapy'], likedItems[0]['mapx']);
                    waypointTitles.add(likedItems[0]['title']); // 제목 추가

                    // 마지막 찜한 장소를 목적지로 설정
                    destinationLocation = LatLng(likedItems.last['mapy'], likedItems.last['mapx']);
                    waypointTitles.add(likedItems.last['title']); // 제목 추가

                    // 찜한 장소가 3개 이상이라면 경유지 설정
                    if (likedItems.length > 2) {
                      for (var i = 1; i < likedItems.length - 1; i++) {
                        double latitude = likedItems[i]['mapy'];
                        double longitude = likedItems[i]['mapx'];
                        waypoints.add(LatLng(latitude, longitude));
                        waypointTitles.add(likedItems[i]['title']); // 제목 추가
                      }
                    }

                    // 경로 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutePage(
                          startLatitude: startLocation!.latitude,
                          startLongitude: startLocation.longitude,
                          destinationLatitude: destinationLocation!.latitude,
                          destinationLongitude: destinationLocation.longitude,
                          waypoints: waypoints, // 경유지 추가
                          waypointTitles: waypointTitles, // 각 장소의 제목 추가
                        ),
                      ),
                    );
                  } catch (e) {
                    // 예외 처리 및 사용자에게 알림
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류 발생: $e')),
                    );
                  }
                },
                child: const Text('경로탐색'),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = likedItems.removeAt(oldIndex);
                      likedItems.insert(newIndex, item);

                      // Firestore에 변경된 순서 업데이트
                      updateLikedPlacesOrder();
                    });
                  },
                  children: [
                    for (int index = 0; index < likedItems.length; index++)
                      Dismissible(
                        key: ValueKey(likedItems[index]['itemId']),
                        background: Container(
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                        ),
                        onDismissed: (direction) {
                          // 좋아요 취소 및 데이터베이스 업데이트
                          removeLikedPlace(likedItems[index]['itemId']);
                          setState(() {
                            likedItems.removeAt(index);
                          });
                        },
                        direction: DismissDirection.endToStart,
                        child: ListTile(
                          leading: likedItems[index]['image'] != null && likedItems[index]['image'].isNotEmpty
                              ? Image.network(
                            likedItems[index]['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image, size: 50),
                          title: Text(likedItems[index]['title'] ?? '이름 없음'),
                          subtitle: Text(likedItems[index]['address'] ?? '주소 정보 없음'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  title: likedItems[index]['title'],
                                  address: likedItems[index]['address'],
                                  image: likedItems[index]['image'],
                                  mapx: likedItems[index]['mapx'],
                                  mapy: likedItems[index]['mapy'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void removeLikedPlace(String placeId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('UserData').doc(uid);

    // Retrieve the current liked items
    DocumentSnapshot snapshot = await userDoc.get();
    List<dynamic> currentLikedItems = List.from(snapshot['likedItems'] ?? []);

    // Find the item to remove
    Map<String, dynamic>? itemToRemove = currentLikedItems.firstWhere(
          (item) => item['itemId'] == placeId,
      orElse: () => null,
    );

    if (itemToRemove != null) {
      await userDoc.update({
        'likedItems': FieldValue.arrayRemove([itemToRemove]),
      });
    }
  }

  void updateLikedPlacesOrder() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('UserData').doc(uid);

    await userDoc.update({
      'likedItems': likedItems,
    });
  }
}

class DetailPage extends StatelessWidget {
  final String? title;
  final String? address;
  final String? image;
  final double? mapx;
  final double? mapy;

  const DetailPage({
  Key? key,
  this.title,
  this.address,
  this.image,

    this.mapx,
    this.mapy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '상세 정보'),
        actions: [
          if (mapx != null && mapy != null)
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(
                      locations: [
                        {'title': title, 'mapx': mapx, 'mapy': mapy},
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image != null && image!.isNotEmpty
                  ? Image.network(image!, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 200),
              const SizedBox(height: 16.0),
              Text(
                title ?? '이름 없음',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8.0),
              Text(
                address ?? '주소 정보 없음',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
