import 'package:learn_with_translation/sqflite/db_helper.dart';

class CurrentUser{
  String? id;
  String? name;
  int? dailyGoal;
  int? score;

  CurrentUser(this.id, this.name, this.dailyGoal, this.score);

  // construct a CurrentUser object with the data given in the map object.
  CurrentUser.fromMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    dailyGoal = map['dailygoal'];
    score = map['score'];
  }

  // send the data of the CurrentUser object to the db.
  Map<String, dynamic> toMap(){
    return{
      DatabaseHelper.columnId : id,
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnDailyGoal : dailyGoal,
      DatabaseHelper.columnScore : score,
    };
  }

}