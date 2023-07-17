import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PodiumFinish {
  final String trackName;
  final DateTime recordDate;
  final int recordLap;
  final String recordAvgTime;
  final String recordFastestLap;
  final int recordPos;

  PodiumFinish(
      {required this.trackName,
      required this.recordDate,
      required this.recordLap,
      required this.recordAvgTime,
      required this.recordFastestLap,
      required this.recordPos});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  late User user;
  late Future<void> _fetchUserFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _fetchUser();
    _initializeFirebase();
  }

  Future<void> _fetchUser() async {
    User currentUser = _auth.currentUser!;
    setState(() {
      user = currentUser;
    });
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Speed Trap',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(user.uid)
                  .collection('Record')
                  .where('recordPos', isLessThanOrEqualTo: 3)
                  .orderBy('recordPos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<PodiumFinish> podiumFinishes =
                    snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return PodiumFinish(
                    trackName: data['trackName'],
                    recordDate: data['recordDate'].toDate(),
                    recordLap: data['recordLap'],
                    recordAvgTime: data['recordAvgTime'],
                    recordFastestLap: data['recordFastestLap'],
                    recordPos: data['recordPos'],
                  );
                }).toList();

                double totalLaps = podiumFinishes.fold(
                    0.0, (sum, item) => sum + item.recordLap);
                double averageFinishPosition = podiumFinishes.fold(
                        0.0, (sum, item) => sum + item.recordPos) /
                    podiumFinishes.length;

                Widget stats = Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.20,
                        minWidth: MediaQuery.of(context).size.width * 0.93,
                        maxWidth: MediaQuery.of(context).size.width * 0.95),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text('All-Time Stats:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  'Total Podium Finishes: ${podiumFinishes.length}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text('Total Laps: $totalLaps',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  'Average Finishing Position: ${averageFinishPosition.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            // You can add more stats here...
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                return Column(
                  children: [
                    stats,
                    if (podiumFinishes.isNotEmpty) ...[
                      SizedBox(height: 10),
                      Text('Podium Finishes',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      CarouselSlider.builder(
                        itemCount: podiumFinishes.length,
                        itemBuilder: (context, index, realIdx) {
                          PodiumFinish finish = podiumFinishes[index];
                          return Card(
                            child: ListTile(
                              title: Text(finish.trackName),
                              subtitle: Text(
                                  'Position: ${finish.recordPos}\nDate: ${finish.recordDate.toString()}'),
                            ),
                          );
                        },
                        options: CarouselOptions(
                            autoPlay: false,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false),
                      ),
                    ]
                  ],
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(user.uid)
                  .collection('SavedTracks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List savedTracks = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  Map<String, dynamic> trackData = data['trackData'];
                  return trackData['name'];
                }).toList();

                return Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Saved Tracks',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    if (savedTracks.isEmpty)
                      Text('No saved tracks',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    if (savedTracks.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: savedTracks.length,
                        itemBuilder: (context, index) {
                          String trackName = savedTracks[index];
                          return ListTile(
                            title: Text(trackName),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
