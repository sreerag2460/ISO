import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/constants/button_decoration.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'package:iso/services/apiEndPoints.dart';
import 'package:iso/widgets/login_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool keyBoardVisible = false;
  String username = "";
  String password = "";
  String error = "error";
  String fcmToken = "";
  var focusNode = FocusNode();
  var unusedFocusNode = FocusNode();
  FToast? fToast;
  bool loading = false;
  DateTime? currentBackPressTime;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime ?? DateTime.now()) >
            Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Press again to exit the app",
          textColor: Colors.white,
          backgroundColor: Colors.grey);
      return Future.value(false);
    }
    return Future.value(true);
  }

  //FUNCTION TO LOGIN //
  login() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "method": "app_login",
      "login_user": username,
      "login_password": password,
    });
    var jsonData = jsonDecode(data.body);
    print(jsonData);
    var token = jsonData["token"];
    print('login token $token');
    var response = jsonData["response_code"];
    var userName = jsonData["username"];
    print(token);
    setState(() {
      error = response.toString();
    });
    if (response == 100) {
      setState(() {
        Provider.of<Data>(context, listen: false).token = token;
        Provider.of<Data>(context, listen: false).userName = userName;
      });
      print("logged in");
      setVisitingFlag();
      getFcmToken();
      Navigator.pushReplacementNamed(context, 'home');
      // setState(() {
      //   loading=false;
      // });
    }
    if (response == 401) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: "Incorrect Username or Password",
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          gravity: ToastGravity.CENTER);
    }
  }
  //FUNCTION TO LOGIN//

  //GET FCM TOKEN//
  getFcmToken() async {
    String? tokenFCM = await FirebaseMessaging.instance.getToken();
    setState(() {
      Provider.of<Data>(context, listen: false).fcmToken = tokenFCM;
    });
    print("tokk${await FirebaseMessaging.instance.getToken()}");
  }
  //GET FCM TOKEN//

  //SET LOGIN FLAG//
  setVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
        "isoToken", Provider.of<Data>(context, listen: false).token ?? '');
    preferences.setString("isoLog", "logged in");
    preferences.setString(
        "isoName", Provider.of<Data>(context, listen: false).userName ?? '');
  }
  //SET LOGIN FLAG//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      setState(() {
        keyBoardVisible = false;
      });
    } else if (MediaQuery.of(context).viewInsets.bottom != 0) {
      setState(() {
        keyBoardVisible = true;
      });
    }
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(unusedFocusNode);
          },
          child: Container(
              color: backgroundGrey,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 9.0,
                        top: MediaQuery.of(context).size.height / 13.1,
                        left: MediaQuery.of(context).size.width / 3.83,
                        right: MediaQuery.of(context).size.width / 3.83),
                    child: Image.asset(
                      'images/isologo.png',
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height / 7.0,
                      width: MediaQuery.of(context).size.height / 7.0,
                    ),
                  ),
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          color: Colors.white,
                        ),
                        width: double.infinity,
                        child: Container(
                            margin: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).size.width / 13.88),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: keyBoardVisible
                                          ? MediaQuery.of(context).size.height /
                                              60
                                          : MediaQuery.of(context).size.height /
                                              14.46),
                                  child: Text(
                                    "Hey,",
                                    style: TextStyle(
                                        fontFamily: "Quicksand",
                                        color: textBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                40.5),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Login Now",
                                    style: TextStyle(
                                        fontFamily: "Quicksand",
                                        color: textBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                33.75),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height: MediaQuery.of(context).size.height /
                                      20.25,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          21.3),
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                        color: textFieldShadow.withOpacity(1),
                                        blurRadius: 10,
                                        offset: Offset(0, 3))
                                  ]),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode);
                                    },
                                    style: TextStyle(
                                        color: hintTextColor,
                                        fontFamily: "Quicksand",
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                54),
                                    decoration: kuserInputButtons.copyWith(
                                      hintText: "Username",
                                    ),
                                    cursorColor: hintTextColor,
                                    onChanged: (value) {
                                      setState(() {
                                        username = value;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height: MediaQuery.of(context).size.height /
                                      20.25,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          42.63),
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                        color: textFieldShadow.withOpacity(1),
                                        blurRadius: 10,
                                        offset: Offset(0, 3))
                                  ]),
                                  child: TextField(
                                    focusNode: focusNode,
                                    onSubmitted: (value) {
                                      if (username.length == 0) {
                                        Fluttertoast.showToast(
                                            msg: "Enter Username",
                                            textColor: Colors.white,
                                            backgroundColor: Colors.grey,
                                            gravity: ToastGravity.CENTER);
                                        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Enter Username")));
                                      } else if (password.length == 0) {
                                        Fluttertoast.showToast(
                                            msg: "Enter Password",
                                            textColor: Colors.white,
                                            backgroundColor: Colors.grey,
                                            gravity: ToastGravity.CENTER);
                                        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Enter Password")));
                                      } else {
                                        setState(() {
                                          loading = true;
                                        });
                                        login();
                                      }
                                    },
                                    style: TextStyle(
                                        color: hintTextColor,
                                        fontFamily: "Quicksand",
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                54),
                                    decoration: kuserInputButtons.copyWith(
                                        hintText: "Password"),
                                    cursorColor: hintTextColor,
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height: MediaQuery.of(context).size.height /
                                      20.25,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          40.5),
                                  child: LoginButton(
                                    color: buttonColor,
                                    textOrLoading: loading == false
                                        ? Text(
                                            "Login",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    54,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor: fabColor,
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                          ),
                                    fontSize:
                                        MediaQuery.of(context).size.height / 54,
                                    onPressed: () {
                                      if (username.length == 0) {
                                        Fluttertoast.showToast(
                                            msg: "Enter Username",
                                            textColor: Colors.white,
                                            backgroundColor: Colors.grey,
                                            gravity: ToastGravity.CENTER);
                                        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Enter Username")));
                                      } else if (password.length == 0) {
                                        Fluttertoast.showToast(
                                            msg: "Enter Password",
                                            textColor: Colors.white,
                                            backgroundColor: Colors.grey,
                                            gravity: ToastGravity.CENTER);
                                        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Enter Password")));
                                      } else {
                                        setState(() {
                                          loading = true;
                                        });
                                        login();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ))),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
