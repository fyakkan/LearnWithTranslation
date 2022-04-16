import 'package:learn_with_translation/models/question.dart';
import 'package:learn_with_translation/models/user_manager_state.dart';

import 'package:flutter/material.dart';
import 'package:learn_with_translation/models/quiz_brain.dart';
import 'package:provider/provider.dart';

QuizBrain quizBrain = QuizBrain();

class QuizPage extends StatefulWidget {
  const QuizPage({
    Key? key,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

const kAppBarColor = Colors.purple;

class _QuizPageState extends State<QuizPage> {
  int score = 0;

  void checkAnswer(String userPickedAnswer) {
    bool isCorrect = false;

    if (userPickedAnswer == quizBrain.getCorrectAnswer()) {
      isCorrect = true;
    } else {
      isCorrect = false;
    }

    setState(() {
      final state = Provider.of<UserManagerState>(context, listen: false);
      if (quizBrain.isFinished()) {
        if (isCorrect) {
          score++;
        }
        state.setScore(score);
        quizBrain.showAlertDialog(context);
        quizBrain.finish();
        quizBrain.reset();
      } else {
        if (isCorrect) {
          score++;
        }
        quizBrain.nextQuestion();
      }
    });
  }

  void castWordListToQuestionList(Map listOfWords) {
    List<Question> questionList = [];
    for (var key in listOfWords.keys) {
      questionList.add(Question(key, listOfWords[key]));
    }
    quizBrain.setQuestionBank(questionList);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<UserManagerState>(context, listen: false);
    castWordListToQuestionList(
      state.wordSets[state.getSelectedWordList()].getWordList(),
    );

    quizBrain.addRandomAnswers();
    quizBrain.getRandomAnswers();

    List<FlatButton> buttons = [];
    quizBrain.checkChoicesAreSame();
    String firstChoose = quizBrain.tempRandomAnswers[0];
    String secondChoose = quizBrain.tempRandomAnswers[1];
    String thirdChoose = quizBrain.tempRandomAnswers[2];
    FlatButton button1 = FlatButton(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 0,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      textColor: Colors.white,
      color: Colors.purple,
      child: Text(
        firstChoose,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      onPressed: () {
        checkAnswer(firstChoose);
        quizBrain.reset();
      },
    );
    FlatButton button2 = FlatButton(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 0,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      textColor: Colors.white,
      color: Colors.purple,
      child: Text(
        secondChoose,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      onPressed: () {
        checkAnswer(secondChoose);
        quizBrain.reset();
      },
    );
    FlatButton button3 = FlatButton(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 0,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      textColor: Colors.white,
      color: Colors.purple,
      child: Text(
        thirdChoose,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      onPressed: () {
        //The user picked true.
        checkAnswer(thirdChoose);
        quizBrain.reset();
      },
    );
    FlatButton correctButton = FlatButton(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 0,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      color: Colors.purple,
      child: Text(
        quizBrain.getCorrectAnswer(),
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        //The user picked false.
        checkAnswer(quizBrain.getCorrectAnswer());
        quizBrain.reset();
      },
    );
    buttons.add(button1);
    buttons.add(button2);
    buttons.add(button3);
    buttons.add(correctButton);
    buttons.shuffle();

    return Scaffold(
        backgroundColor: const Color.fromRGBO(250, 240, 240, 1.0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    quizBrain.getQuestionText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 35.0,
                        color: Colors.purple,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: buttons[0],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: buttons[1],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: buttons[2],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: buttons[3],
              ),
            ),
            /*Row(
              children: scoreKeeper,
            ),*/
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      quizBrain.nextQuestion();
                      checkAnswer(" ");
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.teal,
                      ),
                      child: const Center(
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            height: 1,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      // state.getCurrentUser()!.setScore(score);
                      state.setScore(score);
                      quizBrain.finish();
                    });

                    //
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: const Color(0xFF270434)),
                      child: const Center(
                        child: Text(
                          'Finish',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              height: 1,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            )
            //TODO Score Keeper is here later project we can use
            /*     Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Expanded(
                  child: Text(
                    'Score $score',
                      style: TextStyle(
                          fontSize: 35.0,
                          color: Colors.orangeAccent,

                          fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            )*/
          ],
        ));
  }
}

/*class button extends StatefulWidget {
  const button({Key? key}) : super(key: key);

  @override
  _buttonState createState() => _buttonState();
}

class _buttonState extends State<button> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      textColor: Colors.white,
      color: Colors.purple,
      child: Text(
        'True',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      onPressed: () {
        //The user picked true.
        //     checkAnswer(true);
      },
    );
  }
}*/

