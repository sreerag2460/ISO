import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/widgets/drawer_tab.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class IsoDrawer extends StatefulWidget {
  IsoDrawer(
      {this.onClickHome,
      this.onClickNotification,
      this.onClickProfile,
      this.onClickLogout});
  void Function()? onClickHome;
  void Function()? onClickProfile;
  void Function()? onClickNotification;
  void Function()? onClickLogout;

  @override
  _IsoDrawerState createState() => _IsoDrawerState();
}

class _IsoDrawerState extends State<IsoDrawer> {
  setVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("isoToken", "");
    preferences.setString("isoLog", "logged out");
    preferences.setString("isoName", "");
  }

  //FUNCTION TO MAKE A CALL//
  Future<void> placeCall(String url) async {
    canLaunchUrl(Uri(scheme: 'tel', path: url)).then((value) async {
      await launchUrl(Uri.parse(url));
    }).onError((error, stackTrace) => throw 'Could not launch $url');
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  //FUNCTION TO MAKE A CALL//
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Drawer(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(27),
                      bottomRight: Radius.circular(27)),
                  boxShadow: [
                    BoxShadow(
                        color: textFieldShadow.withOpacity(1),
                        blurRadius: 10,
                        offset: Offset(0, 3)),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 12,
                        left: _size.width / 20),
                    height: _size.height / 14.5,
                    width: _size.width / 6.7,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: profileIconCircle),
                    child: Center(
                      child: Image.asset(
                        'images/sideMenuUser.png',
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20),
                      child: Text(
                        Provider.of<Data>(context, listen: false).userName ??
                            '',
                        style: TextStyle(
                            fontFamily: "Quicksand",
                            fontWeight: FontWeight.bold,
                            fontSize: _size.height / 37,
                            color: homeClientName),
                      )),
                  DrawerTab(
                    text: "Home",
                    image: "images/sideMenuHome.png",
                    top: _size.height / 8,
                    onTap: widget.onClickHome ?? () {},
                  ),
                  DrawerTab(
                    text: "Profile",
                    image: "images/sideMenuProfile.png",
                    top: _size.height / 17,
                    onTap: widget.onClickProfile ?? () {},
                  ),
                  DrawerTab(
                    text: "Notification",
                    image: "images/sideMenuNotification.png",
                    top: _size.height / 17,
                    onTap: widget.onClickNotification ?? () {},
                  ),
                  DrawerTab(
                      text: "Logout",
                      image: "images/sideMenuLogout.png",
                      top: _size.height / 17,
                      onTap: widget.onClickLogout ?? () {})
                ],
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                color: drawerColor,
                child: Column(
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            placeCall("mailto:info@merchantmarketplace.com");
                          });
                          print("mail");
                        },
                        child: Container(
                            child: ContactTab(
                                text: "info@merchantmarketplace.com",
                                image: "images/sideMenuEmail.png",
                                top: _size.height / 17))),
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            placeCall("tel:8882711420");
                          });
                          print("call");
                        },
                        child: Container(
                            child: ContactTab(
                                text: "888-271-1420",
                                image: "images/sideMenuCall.png",
                                top: _size.height / 35))),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
