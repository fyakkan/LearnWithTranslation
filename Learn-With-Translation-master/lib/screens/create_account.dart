import 'package:learn_with_translation/models/user_manager_state.dart';
import 'package:learn_with_translation/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateAccount();
  }
}

class _CreateAccount extends State<CreateAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  var _hidePassword = true;

  @override
  Widget build(
    BuildContext context,
  ) {
    final state = Provider.of<UserManagerState>(context, listen: false);

    return buildCreateAccountPage(context, state);
  }

  //final _textFormFieldKey = GlobalKey<FormState>();

  Widget buildCreateAccountPage(BuildContext context, UserManagerState state) {
    var size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.orange]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            height: size.height * .5,
            width: size.width * .85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepPurple,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(.70),
                    blurRadius: 20,
                    spreadRadius: 4),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      cursorColor: Colors.pink,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.account_circle_outlined,
                          color: Colors.pink,
                        ),
                        hintText: 'Name',
                        prefixText: ' ',
                        hintStyle: TextStyle(color: Colors.purpleAccent),
                        focusColor: Colors.black87,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.tealAccent,
                        )),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      )),
                  SizedBox(
                    height: size.height * .002,
                  ),
                  TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      cursorColor: Colors.pink,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Colors.pink,
                        ),
                        hintText: 'E-Mail',
                        prefixText: ' ',
                        hintStyle: TextStyle(color: Colors.purpleAccent),
                        focusColor: Colors.black87,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.tealAccent,
                        )),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      )),
                  SizedBox(
                    height: size.height * .002,
                  ),
                  TextField(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            tooltip: 'show/hide password',
                            color: Colors.deepOrange,
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: const Icon(Icons.remove_red_eye)),
                        prefixIcon: const Icon(
                          Icons.vpn_key,
                          color: Colors.pink,
                        ),
                        hintText: 'Password',
                        prefixText: ' ',
                        hintStyle: const TextStyle(
                          color: Colors.purpleAccent,
                        ),
                        focusColor: Colors.black,
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.tealAccent,
                        )),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      )),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var result = await _authService.createPerson(
                          _nameController.text,
                          _emailController.text,
                          _passwordController.text);

                      if (result is! String) {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text(
                                  "Successfully registered",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('Okay'),
                                    onPressed: () {
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
                                  "Error: $result",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  ElevatedButton(
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
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
