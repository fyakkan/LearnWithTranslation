import 'dart:ui';

import 'package:learn_with_translation/models/constants.dart';
import 'package:learn_with_translation/models/user_manager_state.dart';
import 'package:flutter/material.dart';

import 'package:learn_with_translation/models/translation_api.dart';
import 'package:learn_with_translation/widgets/translation_text_widget.dart';

import 'package:learn_with_translation/models/languages.dart';
import 'package:provider/provider.dart';

class NewSetPage extends StatefulWidget {
  const NewSetPage({
    Key? key,
  }) : super(key: key);

  final String title = "Create a New Set";

  @override
  State<NewSetPage> createState() => _NewSetPage();
}

class _NewSetPage extends State<NewSetPage> {
  final List<DropdownMenuItem<String>> _dropDownMenuItems = Languages.languages
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  String _selectedLang = "English";

  var apiHelper = TranslationApi();
  late TextEditingController _controller = TextEditingController();

  late String _message = "";
  late String _translation = "";
  var mySet = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _controller.dispose();
    super.dispose();
  }

  void _keepText(String text) {
    setState(() {
      _message = text;
    });
  }

  bool isExist(String translatedMessage) {
    for (var key in mySet.keys) {
      if (mySet[key] == translatedMessage) {
        return true;
      }
    }
    return false;
  }

  void setTranslation(String translatedMessage) {
    if (!isExist(translatedMessage)) {
      _translation = translatedMessage;
    }
  }

  String? validateWord(String value) {
    if (value.isEmpty) {
      return "enter a word";
    }
    return null;
  }

  void keepPairsInMap() {
    if (isExist(_translation)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("already added"),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          label: 'Ok',
        ),
      ));
    }

    if (_message.isNotEmpty &&
        !isExist(_translation) &&
        _translation.isNotEmpty) {
      setState(() {
        mySet[_message] = _translation;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("pair added"),
        duration: const Duration(milliseconds: 500),
        action: SnackBarAction(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          label: 'Ok',
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<UserManagerState>(context, listen: false);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(250, 240, 240, 1.0),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: purple,
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TranslationWidget(
                    message: _message,
                    fromLanguage: "English",
                    toLanguage: _selectedLang,
                    builder: (translatedMessage) {
                      //sendingMessage(translatedMessage);
                      setTranslation(translatedMessage);
                      print("translated message is : " + _translation);
                      return ListTile(
                        leading: const Text(
                          "Translation is :",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        title: Text(_translation),
                      );
                    }),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _controller,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _keepText(value);
                      print(value);
                    }
                  },
                  decoration: InputDecoration(
                    errorText: validateWord(_controller.text),
                    hintText: 'enter a word to translate',
                    labelText: 'text',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                  onPressed: () {
                    keepPairsInMap();
                    setState(() {
                      // make textField and translation empty to be ready for possible inputs.
                      _translation = "";
                      _controller.text = "";
                    });
                  },
                  child: const Text("Add the word pair"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  title: const Text(
                    "Choose a target language:",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                  selected: true,
                  selectedTileColor: purple,
                  contentPadding: const EdgeInsets.all(8.0),
                  trailing: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLang,
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            _selectedLang = newValue;
                          }
                        });
                      },
                      items: _dropDownMenuItems,
                      elevation: 50,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      underline: const SizedBox(),
                      iconSize: 32,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                  child: buildListOfWordPairs(mySet),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (mySet.length >= 4) {
                      showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            late String title = "";
                            return AlertDialog(
                              title: const Text('Please enter a Set Title'),
                              content: TextField(
                                onChanged: (txt) {
                                  setState(() {
                                    title = txt;
                                  });
                                },
                              ),
                              actions: [
                                FlatButton(
                                  child: const Text('Save'),
                                  onPressed: () {
                                    setState(() {
                                      state.addNewSet(
                                          state.getCurrentUser(), title, mySet);
                                    });

                                    Navigator.of(ctx).pop();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Text(
                                'Please enter at least 4 word pairs. You entered ${mySet.length} pairs',
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                FlatButton(
                                  child: const Text('Okay'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListOfWordPairs(Map setOfWords) {
    var keys = setOfWords.keys.toList();

    return ListView.builder(
        //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: keys.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (BuildContext ctx, int i) {
          int reverseIndex = keys.length - 1 - i;
          return buildWordCards(reverseIndex, keys, setOfWords);
        });
  }

  Widget buildWordCards(int reverseIndex, List keys, Map setOfWords) {
    if (setOfWords.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Card(
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (reverseIndex + 1).toString() + " :",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              backgroundColor: Colors.blueGrey,
            ),
            title: Column(
              children: [
                Text(
                  keys[reverseIndex],
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const Divider(
                  thickness: 5,
                ),
                Text(
                  setOfWords[keys[reverseIndex]],
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  setOfWords.remove(keys[reverseIndex]);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("the card deleted"),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      label: 'Ok',
                    ),
                  ));
                });
              },
            ),
          ),
        ),
      );
    } else {
      return const Text("No element added yet.");
    }
  }
}

/*

 */
