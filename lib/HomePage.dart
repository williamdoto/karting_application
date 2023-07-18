import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'LoginPage.dart';
import 'TrackDetail.dart';

class PodiumFinish {
  final String trackName;
  final DateTime recordDate;
  final int recordLap;
  final String recordAvgTime;
  final String recordFastestLap;
  final int recordPos;
  final int recordTotalRacers;
  final double recordPoleGap;
  PodiumFinish({
    required this.trackName,
    required this.recordDate,
    required this.recordLap,
    required this.recordAvgTime,
    required this.recordFastestLap,
    required this.recordPos,
    required this.recordTotalRacers,
    required this.recordPoleGap,
  });
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

  Future<void> signOut() async {
    await _auth.signOut();
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
        actions: <Widget>[
          TextButton(
            onPressed: signOut,
            child: Row(
              children: <Widget>[
                Icon(Icons.logout, color: Colors.black), // Add the icon here
                Padding(
                  padding:
                      EdgeInsets.only(left: 8.0), // Adjust padding as needed
                  child: Text('Logout', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.purple)))),
          ),
        ],
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
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<PodiumFinish> allFinishes = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return PodiumFinish(
                    trackName: data['trackName'],
                    recordDate: data['recordDate'].toDate(),
                    recordLap: data['recordLap'],
                    recordAvgTime: data['recordAvgTime'],
                    recordFastestLap: data['recordFastestLap'],
                    recordPos: data['recordPos'],
                    recordTotalRacers: data['recordTotalRacers'],
                    recordPoleGap: double.parse(data['recordPoleGap']),
                  );
                }).toList();

                double totalLaps =
                    allFinishes.fold(0.0, (sum, item) => sum + item.recordLap);

                double averageFinishPosition =
                    allFinishes.fold(0.0, (sum, item) => sum + item.recordPos) /
                        allFinishes.length;
                double averageTotalRacers = allFinishes.fold(
                        0.0, (sum, item) => sum + item.recordTotalRacers) /
                    allFinishes.length;
                double averageGapToPole = allFinishes.fold(
                        0.0, (sum, item) => sum + item.recordPoleGap) /
                    allFinishes.length;
                // Podium finishes
                return StreamBuilder<QuerySnapshot>(
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
                        recordTotalRacers: data['recordTotalRacers'],
                        recordPoleGap: double.parse(data['recordPoleGap']),
                      );
                    }).toList();

                    Widget stats = Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.24,
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
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                      'Total Podium Finishes: ${podiumFinishes.length}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text('Total Laps: $totalLaps',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                      'Average Finishing Position: ${averageFinishPosition.toStringAsFixed(2)}/${averageTotalRacers.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                      'Average Gap to Pole: ${averageGapToPole.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                ),
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
      const SizedBox(height: 13),
      const Text('Podium Finishes',
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
            enableInfiniteScroll: false,
            aspectRatio: 5/2, // Adjust this to change the height of the cards
        ),
      ),
    ]
  ],
);

                  },
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
                  return data;
                }).toList();

                return Column(
                  children: [
                    const SizedBox(height: 13),
                    const Text('Saved Tracks',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    if (savedTracks.isEmpty)
                      const Text('No saved tracks',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    if (savedTracks.isNotEmpty)
                      Container(
                        height: MediaQuery.of(context).size.height *
                            0.235, // Adjust this value as needed
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: savedTracks.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> trackData = savedTracks[index];
                            String trackName = trackData['trackData']['name'];
                            return ListTile(
                              title: Text(trackName),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrackDetail(
                                      kartPlace: trackData['trackData'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                        ),
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
