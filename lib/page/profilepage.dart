import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:project/api/matchbyid_api.dart';
import 'package:project/page/loginpage.dart';
import 'package:project/page/matchinfopage.dart';
import 'package:project/provider/coins_provider.dart';
import 'package:project/widget/makedismissible.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        color: Colors.white,
        child: Column(children: [
          _buildCoinsSection(),
          _buildMatchFollowingsSection(),
          _buildSignOutSection()
        ]),
      ),
    );
  }

  Widget _buildCoinsSection() {
    return Consumer<CoinModel>(
      builder: (context, model, child) => InkWell(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => _buildCoinsSheet());
        },
        child: Row(children: [
          Icon(
            Icons.monetization_on,
            color: Colors.pink[800],
            size: 30,
          ),
          const SizedBox(
            width: 20,
            height: 50,
          ),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  text: '${model.coins.toString()}.00',
                  style: TextStyle(
                    color: Colors.pink[800],
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          const Text('coins',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
              )),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            size: 17,
          ),
          const SizedBox(
            width: 10,
          ),
        ]),
      ),
    );
  }

  Widget _buildMatchFollowingsSection() {
    return FutureBuilder(
        future: _buildMatchFollowingsSheet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.pink[800],
                  size: 30,
                ),
                const SizedBox(
                  width: 20,
                  height: 50,
                ),
                const Expanded(
                  child: Text(
                    'Match Followings',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            );
          } else {
            return InkWell(
              onTap: () => showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => snapshot.data as Widget),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.pink[800],
                    size: 30,
                  ),
                  const SizedBox(
                    width: 20,
                    height: 50,
                  ),
                  const Expanded(
                    child: Text(
                      'Match Followings',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 17,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _buildSignOutSection() {
    return InkWell(
      onTap: () async {
        String fcmToken = await getFcmToken();
        FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(value.docs[0].id)
                .update({
              'fcmTokens': FieldValue.arrayRemove([fcmToken]),
            }).then((_) async {
              await _updateCoinsInFirestore(
                  Provider.of<CoinModel>(context, listen: false).coins);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Get.offAll(() => const LoginPage(), curve: Curves.easeIn);
            });
          }
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.power_settings_new,
            color: Colors.pink[800],
            size: 30,
          ),
          const SizedBox(
            width: 20,
            height: 50,
          ),
          const Expanded(
              child: Text(
            'Sign out',
            style: TextStyle(fontSize: 17),
          )),
        ],
      ),
    );
  }

  Future<void> _updateCoinsInFirestore(int coins) async {
    try {
      final dbUser = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (dbUser.docs.isNotEmpty) {
        await dbUser.docs[0].reference.update({'coins': coins});
        print('Coins updated in Firestore3');
      }
    } catch (error) {
      print('Error updating coin count in Firestore: $error');
    }
  }

  Future<String> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  Future<Widget> _buildMatchFollowingsSheet() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('followedMatch')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    final List<int> matchIds = [];
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        matchIds.add(doc['matchId']);
      }
    }

    final matchData = await fetchMatchByID(matchIds);

    return MakeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (_, controllers) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Match Followings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                    controller: controllers,
                    children: matchData.matches.isNotEmpty
                        ? matchData.matches
                            .map<Widget>((match) => _buildMatchItem(match))
                            .toList()
                        : []),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsSheet() {
    return MakeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (_, controllers) => Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: controllers,
                    children: const [
                      Text('Coins',
                      textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                )));
  }

  Widget _buildMatchItem(Map<String, dynamic> match) {
    if (match['status'] == 'FINISHED') {
      return const SizedBox.shrink();
    }
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            FirebaseFirestore.instance
                .collection('followedMatch')
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('matchId', isEqualTo: match['id'])
                .get()
                .then((value) {
              if (value.docs.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('followedMatch')
                    .doc(value.docs[0].id)
                    .delete();
              }
            }).then((value) {
              setState(() {
                _buildMatchFollowingsSheet();
                Get.back();
              });
            });
          },
          icon: Icons.delete,
          backgroundColor: Colors.red,
          label: 'Unfollow',
          borderRadius: BorderRadius.circular(20.0),
        )
      ]),
      child: InkWell(
        onTap: () => {
          Get.to(
            () => MatchInfoPage(
              match: match,
            ),
            transition: Transition.rightToLeft,
          )
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 105,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 55, height: 55, child: crestHomeWidget),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            match['homeTeam']['shortName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('VS',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  width: 105,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 55, height: 55, child: crestAwayWidget),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            match['awayTeam']['shortName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
}
