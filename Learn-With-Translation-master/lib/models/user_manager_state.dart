import 'package:learn_with_translation/models/word_set.dart';
import 'package:learn_with_translation/services/user_info_service.dart';
import 'package:learn_with_translation/sqflite/db_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'current_user.dart';

class UserManagerState extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  var users = [];
  int? _dailyGoal; //late int _dailyGoal = 5;
  late List<WordSet> wordSets = [];
  int? _score; //late int _score = 0;
  String? _userName; //late String _userName = "";
  late User _currentUser;
  late int _selectedListOfCurrentUser;
  final UserInfoService _userInfoService = UserInfoService();

  UserManagerState();

  int getSelectedWordList() {
    return _selectedListOfCurrentUser;
  }

  void setSelectedWordList(int index) {
    _selectedListOfCurrentUser = index;
  }

  Future<void> setCurrentUser(User currentUser) async {
    _currentUser = currentUser;
    notifyListeners();
  }

  User getCurrentUser() {
    return _currentUser;
  }

  String? getCurrentUserName() {
    return _userName;
  }

  Future<void> setUserName() async {
    final String? name = await _userInfoService.fetchUserName(_currentUser);
    _userName = name!;

    notifyListeners();
  }

  Future<void> fetchScore() async {
    final int score = await _userInfoService.getUserScore(_currentUser);
    _score = score;
    notifyListeners();
  }

  // int? getScore() {
  //   fetchScore();
  //   return _score;
  // }

  void setScore(int score) async {
    final CurrentUser? user = await getCurrentUserData();
    int newScore = 0;
    if (user != null && user.score != null) {
      int? currentSore = user.score;
      newScore = (currentSore! + score);
    }
    _score = newScore;

    update(_currentUser.uid, _userName!, _dailyGoal!, _score!);

    _userInfoService.setScore(_currentUser, _score!);

    notifyListeners();
  }

  Future<void> fetchWordSets() async {
    final List<WordSet> wordsets =
        await _userInfoService.getWordSets(_currentUser);
    wordSets = wordsets;
    notifyListeners();
  }

  Future<List<WordSet>> getWordSets() async {
    await fetchWordSets();
    return wordSets;
  }

  void addNewSet(User user, title, Map newSet) {
    WordSet ws = WordSet(title, newSet);
    _userInfoService
        .addWordSet(user, ws)
        .catchError((error) => print("Error: $error"));
    wordSets.add(ws);
    notifyListeners();
  }

  Future<void> fetchDailyGoal() async {
    final int goal = await _userInfoService.getDailyGoal(_currentUser);
    _dailyGoal = goal;
    notifyListeners();
  }

  void delete(String id) async {
    final deleted = await dbHelper.delete(id);
    users.removeWhere((element) => element.id == id);

    print("row deleted $deleted");
  }

  // int getDailyGoal() {
  //   try{
  //     fetchDailyGoal();
  //     return _dailyGoal;
  //   }catch(e){
  //     print(e);
  //     return -5;
  //   }
  // }

  void setDailyGoal(int goal) {
    _userInfoService
        .updateDailyGoal(_currentUser, goal)
        .catchError((error) => print("error: $error"));

    _dailyGoal = goal;
    notifyListeners();
  }

  void loadUser(String userId) async {
    await setUserName();
    await fetchDailyGoal();
    await fetchScore();

    final allRows = await dbHelper.queryAllRows();
    print("user checking");

    if (allRows != null) {
      if (allRows.isEmpty) {
        print("inside1");

        Map<String, dynamic> row = {
          DatabaseHelper.columnId: userId,
          DatabaseHelper.columnName: _userName,
          DatabaseHelper.columnDailyGoal: _dailyGoal,
          DatabaseHelper.columnScore: _score
        };

        CurrentUser user = CurrentUser.fromMap(row);

        print("inside2");

        final id = await dbHelper.insert(user);
        print("local user inserted $id");
      } else {
        // öyle biri yoksa db'de nasıl update etsin?
        update(_currentUser.uid, _userName!, _dailyGoal!, _score!);
        print("user exists");
      }
    }
  }

  void update(String id, String name, int dailyGoal, int score) async {
    CurrentUser user = CurrentUser(id, name, dailyGoal, score);
    final rowAffected = await dbHelper.update(user);

    print("updated $rowAffected .");
  }

  Future getCurrentUserData() async {
    await _queryAll();

    print("num of users: ${users.length}");

    for (CurrentUser current in users) {
      if (current.id == _currentUser.uid) {
        return current;
      }
    }

    return null;
  }

  Future _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    users.clear();

    print('query done');
    allRows?.forEach((row) {
      users.add(CurrentUser.fromMap(row));
    });
  }

  void addUser(Map<String, dynamic> userInfos) {
    // _id++;
    //
    // user.id = _id;
    // users.add(user);
    //
    // notifyListeners();
  }

  // void updateUser(User givenUser){
  //   for(int i=0; i<users.length; i++){
  //     if(users[i].id == givenUser.id){
  //
  //     }
  //   }
  // }

  void removeUser(String userID) {
    // users.remove(user);
    // notifyListeners();
  }

  void removeSet(String userID, WordSet setToBeDeleted) {
    // user.wordSets.remove(setToBeDeleted);
    // notifyListeners();
  }
}
