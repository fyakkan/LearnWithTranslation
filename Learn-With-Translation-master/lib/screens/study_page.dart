import 'package:learn_with_translation/models/constants.dart';
import 'package:learn_with_translation/models/user_manager_state.dart';
import 'package:learn_with_translation/models/word_set.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_set_page.dart';
import 'quiz_page.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({Key? key}) : super(key: key);

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  List<WordSet> listSet = [];
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<UserManagerState>(context, listen: false);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: purple,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back)),
          title: const Text("Study Page"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: FutureBuilder(
              future: state.getWordSets(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something Went Wrong :(');
                } else {
                  if (snapshot.hasData) {
                    listSet = snapshot.data;
                    return Column(
                      children: [
                        buildListCheckMessage(state, context),
                        const SizedBox(
                          height: 50,
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext ctx, int i) {
                            if (snapshot.data.isNotEmpty) {
                              return TextButton(
                                onPressed: () {
                                  state.setSelectedWordList(i);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const QuizPage()));
                                },
                                child: Container(
                                  height: 50,
                                  width: size.width * .80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.lime),
                                  child: Center(
                                    child: Text(
                                      '${i + 1} : ${snapshot.data[i].getSetTitle()} (${snapshot.data[i].getWordList().length} words)',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                height: 50,
                                width: size.width * .4,
                                color: Colors.pinkAccent,
                                child: const Text(
                                    "The user does not have word set yet."),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
              },
            ),
          ),
        ));
  }

  Widget buildListCheckMessage(UserManagerState state, BuildContext context) {
    if (listSet.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.purple),
          child: const Center(
            child: Text(
              'Select a Set to Study',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Container(
                height: 50,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.purple),
                child: const Center(
                  child: Text(
                    "You haven't created any set yet.",
                    style: TextStyle(fontSize: 20, color: Colors.yellow),
                  ),
                )),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.teal),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const NewSetPage()));
            },
            child: Container(
              height: 50,
              width: 100,
              child: const Center(
                child: Text(
                  'Create a Set',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
