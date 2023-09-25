import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'package:iso/services/apiEndPoints.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({this.onClose});
  final Function? onClose;
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notification> notificationFetched = [];
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int currentPage = 1;
  //FUNCTION TO FETCH NOTIFICATIONS//
  Future<bool> fetchNotification({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        currentPage = 1;
      });
    }
    var data = await http.post(Uri.parse(baseUrl), body: {
      "method": "fetch_notes",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "page": "$currentPage"
    });
    var jsonData = jsonDecode(data.body);
    var statusCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["data"];

    if (statusCode == 100) {
      for (var item in realData) {
        Notification notification = Notification(
            notes: item["notes"],
            created: DateTime.parse(item["created"]),
            createdBy: item["company_name"]);
        setState(() {
          notificationFetched.add(notification);
        });
      }
      currentPage++;
      return true;
    } else {
      return false;
    }
  }

  //FUNCTION TO FETCH NOTIFICATIONS//
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNotification();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            child: SafeArea(
                child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: _size.height / 47.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          height: _size.width > 650 ? _size.height / 33 : null,
                          width: _size.width > 650 ? _size.width / 20 : null,
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 15),
                          child: Image.asset(
                            "images/drawerIcon.png",
                            fit: _size.width > 650 ? BoxFit.fill : BoxFit.none,
                          ),
                        ),
                      ),

                      Container(
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.bold,
                              fontSize: _size.height / 54,
                              color: homeAmountColor),
                        ),
                      ),

//                          GestureDetector(
//                            onTap: widget.onClose,
                      Container(
                        height: _size.width > 650 ? _size.height / 33 : null,
                        width: _size.width > 650 ? _size.width / 20 : null,
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 15),
//                              child: Image.asset("images/close.png",fit: _size.width>650?BoxFit.fill:BoxFit.none,),
                      ),
//                          )
                    ],
                  ),
                ),
                notificationFetched.isNotEmpty
                    ? Container(
                        height: _size.height,
                        width: double.infinity,
                        child: SmartRefresher(
                          controller: refreshController,
                          enablePullUp: true,
                          onRefresh: () async {
                            notificationFetched.clear();
                            final result =
                                await fetchNotification(isRefresh: true);
                            if (result) {
                              refreshController.refreshCompleted();
                            } else {
                              refreshController.refreshFailed();
                            }
                          },
                          onLoading: () async {
                            final result = await fetchNotification();
                            if (result) {
                              refreshController.loadComplete();
                            } else {
                              refreshController.loadFailed();
                            }
                          },
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: notificationFetched.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  // height: _size.height/10.95,
                                  width: _size.width / 1.15,
                                  margin: EdgeInsets.only(
                                      top: _size.height / 42.63,
                                      left: _size.width / 25,
                                      right: _size.width / 25),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                textFieldShadow.withOpacity(1),
                                            blurRadius: 10,
                                            offset: Offset(0, 3)),
                                      ]),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: _size.height / 54,
                                            left: _size.width / 18.75,
                                            right: _size.width / 20.27),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              notificationFetched[index]
                                                      .createdBy ??
                                                  '',
                                              style: TextStyle(
                                                  fontFamily: "Quicksand",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      _size.height / 57.86,
                                                  color: homeClientName),
                                            ),
                                            // Container(
                                            //   height: _size.width>650?_size.height/84.46:null,
                                            //   width: _size.width>650?_size.width/24.19:null,
                                            //   child: Image.asset('images/eyeGreen.png',fit: _size.width>650?BoxFit.fill:BoxFit.none,),)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 5,
                                            left: _size.width / 18.75,
                                            right: _size.width / 20.27),
                                        child: Row(
                                          children: [
                                            Container(
                                                width: _size.width / 1.23,
                                                // margin: EdgeInsets.only(left: 5),
                                                child: Text(
                                                    notificationFetched[index]
                                                            .notes ??
                                                        '',
                                                    maxLines: 10,
                                                    style: TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize:
                                                            _size.height / 62.3,
                                                        color:
                                                            notificationStatus))),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 10,
                                                  bottom: 10,
                                                  top: 10),
                                              child: Text(
                                                  "${notificationFetched[index].created?.month}-${notificationFetched[index].created?.day}-${notificationFetched[index].created?.year}",
                                                  style: TextStyle(
                                                      fontFamily: "Quicksand",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          _size.height / 81,
                                                      color:
                                                          notificationDate))),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ),
                      )
                    : Container(
                        height: _size.height,
                        margin: EdgeInsets.only(top: 10),
                        child: Center(child: Text('No notification found')
                            // CircularProgressIndicator(
                            //   backgroundColor: fabColor,
                            //   valueColor:
                            //       new AlwaysStoppedAnimation<Color>(Colors.white),
                            // ),
                            ),
                      ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

class Notification {
  final String? notes;
  final DateTime? created;
  final String? createdBy;
  Notification({this.created, this.notes, this.createdBy});
}
