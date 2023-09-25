import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  getVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString("isoToken");
    var log = preferences.getString("isoLog");
    var userName = preferences.getString("isoName");
    if (log == "logged in") {
      setState(() {
        Provider.of<Data>(context, listen: false).token = token;
        Provider.of<Data>(context, listen: false).userName = userName;
      });
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, 'home');
      });
    } else {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, 'login');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    getVisitingFlag();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: _size.height,
        width: _size.width,
        color: Colors.white,
        child: Center(
          child: Container(
            width: _size.width > 650 ? _size.width / 1.66 : null,
            height: _size.width > 650 ? _size.height / 16.875 : null,
            child: Image.asset(
              'images/isologo.png',
              fit: BoxFit.contain,
              height: _size.height / 5.5,
              width: _size.height / 5.5,
            ),
          ),
        ),
      ),
    );
  }
}
