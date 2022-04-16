import 'package:learn_with_translation/screens/quiz_page.dart';
import 'package:flutter/material.dart';

import 'question.dart';

class QuizBrain {
  int _questionNumber = 0;

  List<Question> _questionBank = [];

  void setQuestionBank(List<Question> questionList) {
    _questionBank = questionList;
  }

  final List<String> _randomAnswers = [];
  List<String> tempRandomAnswers = [];
  void checkChoicesAreSame() {
    for (int i = 0; i <= 2; i++) {
      print('$i');
      if (quizBrain.getCorrectAnswer() == quizBrain.tempRandomAnswers[i]) {
        quizBrain.tempRandomAnswers.removeAt(i);
      }
    }
  }

  void addRandomAnswers() {
    int size;
    size = _questionBank.length;
    int i = 0;
    while (size > i) {
      _randomAnswers.add(_questionBank[i].trueAnswer);
      i++;
    }
  }

  List getRandomAnswers() {
    String rAnswer1;
    String rAnswer2;
    String rAnswer3;
    String rAnswer4;
    rAnswer1 = (_randomAnswers..shuffle()).first;

    rAnswer2 = _randomAnswers[1];

    rAnswer3 = _randomAnswers[2];

    rAnswer4 = _randomAnswers[3];

    tempRandomAnswers.add(rAnswer1);
    tempRandomAnswers.add(rAnswer2);
    tempRandomAnswers.add(rAnswer3);
    tempRandomAnswers.add(rAnswer4);

    return tempRandomAnswers;
  }

  void nextQuestion() {
    if (_questionNumber < _questionBank.length - 1) {
      _questionNumber++;
    }
  }

  String getQuestionText() {
    return _questionBank[_questionNumber].questionText;
  }

  String getCorrectAnswer() {
    return _questionBank[_questionNumber].trueAnswer;
  }

  bool isFinished() {
    if (_questionNumber == _questionBank.length - 1) {
      return true;
    } else {
      return false;
    }
  }

  reset() {
    tempRandomAnswers.clear();
    _randomAnswers.clear();
  }

  finish() {
    _questionNumber = 0;
  }

  showAlertDialog(BuildContext context) {
    // Create button
    // ignore: non_constant_identifier_names
    Widget ReturnBack = FlatButton(
      child: const Text("Return Study Page"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Congratulations"),
      content: const Text("It is end of the quiz."),
      actions: [
        ReturnBack,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
