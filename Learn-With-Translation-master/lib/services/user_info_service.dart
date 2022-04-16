import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_with_translation/models/word_set.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoService {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  late String uid;

  void setUid(String uid) {
    uid = uid;
  }

  Future<String?> fetchUserName(User user) async {
    try {
      String userName;
      var snapshot = await _usersRef.doc(user.uid).get();
      Map<String, dynamic> mapData = snapshot.data() as Map<String, dynamic>;
      userName = mapData['username'];

      print("get username method works");
      print(mapData['username']);

      print("====== By Document Snapshot ====");

      print("username is: ${mapData['username']}");
      print("user email is: ${mapData['email']}");

      return userName;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> getUserScore(User user) async {
    print("get user score method works");
    try {
      var userRef = _usersRef.doc(user.uid);

      // DocumentSnapshot:
      var response = await userRef.get();
      Map<String, dynamic> mapData = response.data()
          as Map<String, dynamic>; // we have data in map structure

      print("====== By Document Snapshot ====");

      print("username is: ${mapData['username']}");
      print("user email is: ${mapData['email']}");
      print("user score is: ${mapData['score']}");

      return mapData['score'];
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<void> setScore(User user, int score) async {
    return _usersRef
        .doc(user.uid)
        .update({'score': score})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateDailyGoal(User user, int goal) {
    return _usersRef
        .doc(user.uid)
        .update({'dailygoal': goal})
        .then((value) => print("dalily goal updated"))
        .catchError((error) => print("failed to update daily goal: $error"));
  }

  Future<int> getDailyGoal(User user) async {
    int result = 5;
    try {
      var response = await _usersRef.doc(user.uid).get();
      Map<String, dynamic> mapData = response.data() as Map<String, dynamic>;
      result = mapData['dailygoal'];
      return result;
    } catch (e) {
      print(e);
      return result;
    }
  }

  Future<void> addWordSet(User user, WordSet wordSet) async {
    print("addWordSet method works");

    var userRef = _usersRef.doc(user.uid);

    return userRef
        .collection('wordsets')
        .add(
            {"title": wordSet.getSetTitle(), 'wordlist': wordSet.getWordList()})
        .then((value) => print("wordSet Added"))
        .catchError((error) => print("Failed to add wordSet: $error"));
  }

  Future<dynamic> getWordSets(User user) async {
    try {
      var wordSetsRef =
          await _usersRef.doc(user.uid).collection('wordsets').get();
      var wordSetList = wordSetsRef.docs;

      List<WordSet> wordSets = [];
      for (var snapshot in wordSetList) {
        Map<String, dynamic> wordsetData = snapshot.data();
        WordSet ws = WordSet(wordsetData['title'], wordsetData['wordlist']);
        wordSets.add(ws);
      }
      return wordSets;
    } catch (e) {
      print(e);
      return 'an error occurred';
    }
  }
}
