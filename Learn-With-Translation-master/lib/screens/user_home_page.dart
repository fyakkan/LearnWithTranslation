import 'dart:async';

import 'package:learn_with_translation/models/current_user.dart';
import 'package:learn_with_translation/shared_preferences/sign_in_data.dart';
import 'package:learn_with_translation/models/constants.dart';
import 'package:learn_with_translation/models/user_manager_state.dart';
import 'package:learn_with_translation/screens/study_page.dart';
import 'package:learn_with_translation/services/auth_service.dart';
import 'package:learn_with_translation/sqflite/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'new_set_page.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Home(
      title: 'Welcome',
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  late int _dailyGoal;
  late int _score;
  late double _percentage = 0;
  late UserManagerState _state;
  late CurrentUser currentUser;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  final CurrentUser initialUser = CurrentUser("0", "user", 5, 0);
  var users = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    final allRows = await dbHelper.queryAllRows();

    setState(() {
      users.clear();

      allRows?.forEach((row) {
        users.add(CurrentUser.fromMap(row));
      });
    });
    //print("${users[0].name}");

    for (CurrentUser current in users) {
      if (current.id == _state.getCurrentUser().uid) {
        return current;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final AuthService _auth = AuthService();
    _state = Provider.of<UserManagerState>(context, listen: false);
    final String? currentUserName =
        _state.getCurrentUser() == null ? "" : _state.getCurrentUserName();

    return _state.getCurrentUser() != null
        ? FutureBuilder(
            future: loadData(), //_state.getCurrentUserData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              } else {
                if (snapshot.hasData) {
                  String? id;
                  String? name;

                  currentUser = snapshot.data;
                  id = currentUser.id;
                  name = currentUser.name;
                  _dailyGoal = currentUser.dailyGoal!;
                  _score = currentUser.score!;

                  print("current score is : $_score");
                  _percentage = calculatePercentage();
                  return Scaffold(
                      backgroundColor: background,
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: purple,
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                SignInData.sharedClear();
                                _state.delete(id!);
                                _auth.signOut();
                              });
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Log Out",
                                  style: TextStyle(
                                      fontSize: 18, color: background),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 2, 0),
                                  child: Icon(
                                    Icons.logout,
                                    size: 28,
                                    color: background,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        title: Text(
                          widget.title + ' ' + currentUserName.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      body: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: CircularPercentIndicator(
                                  radius: 100,
                                  percent: _percentage,
                                  circularStrokeCap: CircularStrokeCap.butt,
                                  lineWidth: 20.0,
                                  progressColor: Colors.green,
                                  center: Text(
                                    '%${(_percentage * 100).ceil()}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  animation: true,
                                  animateFromLastPercent: true,
                                  footer: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Progress: $_score / $_dailyGoal",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 28.0,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  height: 100,
                                  width: size.width * .7,
                                  decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Change Daily Goal",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                int newGoal = _dailyGoal;

                                                if (newGoal > 0) {
                                                  newGoal--;
                                                  _state.update(id!, name!,
                                                      newGoal, _score);
                                                  _state.setDailyGoal(newGoal);
                                                }
                                              });
                                            },
                                            child: const Icon(Icons.remove),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  const CircleBorder()),
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(15)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                            ),
                                          ),
                                          Text(
                                            _dailyGoal.toString(),
                                            style: const TextStyle(
                                                fontSize: 32,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                int newGoal = _dailyGoal;
                                                newGoal++;
                                                _state.update(id!, name!,
                                                    newGoal, _score);
                                                _state.setDailyGoal(newGoal);
                                              });
                                            },
                                            child: const Icon(Icons.add),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  const CircleBorder()),
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(15)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(36, 24, 36, 8),
                                child: FlatButton(
                                  color: purple,
                                  highlightColor: Colors.purple,
                                  splashColor: Colors.purple,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NewSetPage(),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'New Set',
                                      style: TextStyle(
                                          color: background,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.0,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(36, 8, 36, 8),
                                child: FlatButton(
                                  color: purple,
                                  highlightColor: Colors.grey,
                                  splashColor: Colors.grey,
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const StudyPage(),
                                    //   ),
                                    // );
                                    navigateStudyPage();
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Study Page',
                                      style: TextStyle(
                                          color: background,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.0,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
            })
        : const Scaffold(body: Center(child: Text("No user Found")));
  }

  double calculatePercentage() {
    double result = 0;
    result = _score / _dailyGoal;
    if (result >= 1) {
      return 1;
    } else {
      print(result); // debug print.
      return result;
    }
  }

  void refreshData() {
    calculatePercentage();
  }

  FutureOr onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  void navigateStudyPage() {
    Route route = MaterialPageRoute(builder: (context) => const StudyPage());
    Navigator.push(context, route).then(onGoBack);
  }
}
