import 'package:learn_with_translation/shared_preferences/sign_in_data.dart';
import 'package:learn_with_translation/models/user_manager_state.dart';
import 'package:learn_with_translation/screens/user_home_page.dart';
import 'package:learn_with_translation/services/auth_service.dart';
import 'package:learn_with_translation/services/user_info_service.dart';
import 'package:learn_with_translation/sqflite/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account.dart';

class LogIn extends StatefulWidget {
  const LogIn({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LogInState();
  }
}

class _LogInState extends State<LogIn> {
  final dbHelper = DatabaseHelper.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final SharedPreferences signInObject;

  final AuthService _authService = AuthService();
  final UserInfoService _userInfoService = UserInfoService();

  bool _isRememberMe = false;

  var _hidePassword = true;

  @override
  void initState() {
    super.initState();
    initSignInPref();
  }

  void initSignInPref() async {
    signInObject = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildLogInBody();
  }

  //final user = User.withoutInfo();
  //final _textFormFieldKey = GlobalKey<FormState>();

  //var isValid = false;
  //_TextFormFieldKey.currentState.value;

  Widget buildLogInBody() {
    final state = Provider.of<UserManagerState>(context, listen: false);
    var size = MediaQuery.of(context).size;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (SignInData.getLogin &&
        _emailController.text.isEmpty &&
        _passwordController.text.isEmpty) {
      setState(() {
        _emailController.text = SignInData.getMail!;
        _passwordController.text = SignInData.getPassword!;
      });
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.orange]),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            height: isPortrait ? size.height * .5 : size.height * .8,
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
                    height: size.height * .003,
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
                  buildCheckBox(SignInData.getLogin, size),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var user = await _authService.signIn(
                          _emailController.text, _passwordController.text);

                      if (user is! String) {
                        if (_isRememberMe) {
                          SignInData.saveMail(_emailController.text);
                          SignInData.savePassword(_passwordController.text);
                          SignInData.login();
                          //dispose();
                        }
                        // user is! String
                        print(user.uid is String);
                        _userInfoService.setUid(user.uid);
                        //await _userInfoService.fetchUserName(user);
                        await state.setCurrentUser(user);
                        await _insert(user.uid, state);

                        BuildContext? dialogContext;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            dialogContext = context;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        Future.delayed(const Duration(milliseconds: 5000), () {
                          setState(() {
                            Navigator.pop(dialogContext!);

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const UserHomePage()));
                          });
                        });

                        //await state.setUserName();

                        // Navigator.of(context).pushReplacement(MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         const UserHomePage()));
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Text(
                                user,
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
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const CreateAccount();
                        }));
                      },
                      child: const Text(
                        "Register, instead",
                        style: TextStyle(color: Colors.pinkAccent),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCheckBox(bool getLogin, Size size) {
    if (getLogin == false) {
      return Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Remember me'),
              Checkbox(
                onChanged: (bool? value) {
                  setState(
                    () {
                      _isRememberMe = value!;
                      // if(_isRememberMe == true){
                      //   //??
                      // }
                      print(_isRememberMe);
                    },
                  );
                },
                activeColor: Colors.green,
                value: _isRememberMe,
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }

  Future<void> _insert(String userId, UserManagerState state) async {
    print("inserting");
    state.loadUser(userId);
  }
}
