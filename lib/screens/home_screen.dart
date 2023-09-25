import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'package:iso/screens/notification_screen.dart';
import 'package:iso/screens/profile_page.dart';
import 'package:iso/services/apiEndPoints.dart';
import 'package:iso/services/utilities.dart';
import 'package:iso/widgets/home_screen_display_box.dart';
import 'package:iso/widgets/home_screen_circle.dart';
import 'package:iso/widgets/dotted_separator.dart';
import 'package:iso/widgets/iso_drawer.dart';
import 'package:iso/widgets/rounded_button.dart';
import 'package:iso/constants/button_decoration.dart';
import 'package:iso/widgets/date_widget.dart';
import 'package:iso/widgets/rounded_button_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool searchIconPressed = false;
  bool filterIconPressed = false;

  bool homeScreen = true;
  bool profileScreen = false;
  bool notificationScreen = false;

  double? screenHeight;
  double? screenWidth;

  bool tab = false;
  bool phone = false;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? firstToDate = DateTime(2008, 1);
  DateTime? empty;

  DateFormat? formatter;
  String? formatted;

  List<Dashboard> dashboardDetails = [];

  String keyword = "";

  int currentPage = 1;

  TextEditingController controller = TextEditingController();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  var unusedFocusNode = FocusNode();

  Timer? _debounce;

  bool loading = true;
  DateTime? currentBackPressTime;

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

  //SHOW BOTTOM SHEET//
  showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: Color(0xff757575),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: homeBoxShadow, width: 1),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 35),
                          child: Text("Do you want to logout",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height /
                                      47.65,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Quicksand",
                                  color: uploadDocumentsTitle)),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 25,
                              bottom: MediaQuery.of(context).size.height / 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                height:
                                    MediaQuery.of(context).size.height / 20.25,
                                // margin: EdgeInsets.only(left:phone?MediaQuery.of(context).size.width/13:MediaQuery.of(context).size.width/18),
                                child: Roundedbutton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  color: homeBoxColor,
                                  text: "Cancel",
                                  textColor: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 54,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                height:
                                    MediaQuery.of(context).size.height / 20.25,
                                // margin: EdgeInsets.only(left:phone?MediaQuery.of(context).size.width/13:MediaQuery.of(context).size.width/18),
                                child: Roundedbutton(
                                  onPressed: () {
                                    setVisitingFlag();
                                    Navigator.pushReplacementNamed(
                                        context, "login");
                                  },
                                  color: fabColor,
                                  text: "Logout",
                                  fontSize:
                                      MediaQuery.of(context).size.height / 54,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
  //SHOW BOTTOM SHEET//

  // DATE PICKER IOS AND ANDROID FUNCTION START//

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2008, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        firstToDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: firstToDate ?? DateTime.now(),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedFromDate)
      //     formatter = DateFormat('yMd');
      // formatted = formatter.format(picked);

      setState(() {
        selectedToDate = picked;
      });
  }

  Future<void> _selectFromDateIOS(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstToDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    setState(() {
      selectedFromDate = pickedDate;
      firstToDate = pickedDate;
    });
    if (pickedDate != null && pickedDate != selectedFromDate)
      setState(() {
        selectedFromDate = pickedDate;
      });
    // final DateTime? picked = await DatePicker.showDatePicker(context,
    //     // theme: DatePickerTheme(containerHeight: 210.0),
    //     theme: DatePickerThemeData(),
    //     showTitleActions: true,
    //     minTime: DateTime(2008, 1, 1),
    //     maxTime: DateTime.now(), onConfirm: (date) {
    //   setState(() {
    //     selectedFromDate = date;
    //     firstToDate = date;
    //   });
    // }, currentTime: DateTime.now(), locale: LocaleType.en);
    // if (picked != null && picked != selectedFromDate)
    //   setState(() {
    //     selectedFromDate = picked;
    //   });
  }

  Future<void> _selectToDateIOS(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstToDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    setState(() {
      selectedFromDate = pickedDate;
      firstToDate = pickedDate;
    });
    if (pickedDate != null && pickedDate != selectedFromDate)
      setState(() {
        selectedFromDate = pickedDate;
      });
    // final DateTime? picked = await DatePicker.showDatePicker(
    //   context,
    //   theme: DatePickerThemeData(),
    //   showTitleActions: true,
    //   minTime: firstToDate,
    //   maxTime: DateTime.now(),
    //   onConfirm: (date) {
    //     setState(() {
    //       selectedToDate = date;
    //     });
    //   },
    //   currentTime: DateTime.now(),
    //   locale: LocaleType.en,
    // );
    // if (picked != null && picked != selectedFromDate)
    //   setState(() {
    //     selectedToDate = picked;
    //   });
  }
  // DATE PICKER IOS AND ANDROID FUNCTION END//

  //SEND FCM TOKEN//
  sendFCMToken() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "method": "send_fcm_token",
      "token": Provider.of<Data>(context, listen: false).token,
      "fcm_token": Provider.of<Data>(context, listen: false).fcmToken
    });

    var jsonData = jsonDecode(data.body);
    print("thokkotu${Provider.of<Data>(context, listen: false).token}");
    print("machane$jsonData");
  }
  //SEND FCM TOKEN//

  //FUNCTION TO FETCH REVENUE/FUNDS STATUS//
  getStatus() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "method": "get_revenue_fund_stats",
      "token": Provider.of<Data>(context, listen: false).token,
    });
    print("statusCode${data.statusCode}");
    print('data $data');
    var jsonData = jsonDecode(data.body);
    print('jsonData ${data.body}');
    if (jsonData.isNotEmpty) {
      var response = jsonData["response_code"];
      print("response$response");
      var totalFunding = jsonData["response_data"]["data"]["totalFunding"];
      var totalFundingAmount =
          jsonData["response_data"]["data"]["totalFundingAmount"];
      var totalRevenue = jsonData["response_data"]["data"]["totalRevenue"];
      print("data$jsonData");

      if (response == 100) {
        print("totalFunding$totalFunding");
        // print(totalFundingAmount);
        // print(totalRevenue);
        setState(() {
          Provider.of<Data>(context, listen: false).totalFunding = totalFunding;
          Provider.of<Data>(context, listen: false).totalFundingAmount =
              totalFundingAmount;
          Provider.of<Data>(context, listen: false).totalRevenue = totalRevenue;
        });
      }
    }
  }
  //FUNCTION TO FETCH REVENUE/FUNDS STATUS//

  //FUNCTION TO FETCH DASHBOARD//
  Future<bool> fetchDashBoard({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        currentPage = 1;
      });
    }
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "method": "dashboard",
      "token": Provider.of<Data>(context, listen: false).token,
      "keyword": keyword,
      "page": currentPage.toString(),
      "from": selectedFromDate != null
          ? selectedFromDate.toString().substring(0, 10)
          : "",
      "to": selectedToDate != null
          ? selectedToDate.toString().substring(0, 10)
          : ""
    });
    var jsonData = jsonDecode(data.body);
    var response = jsonData["response_code"];
    print("fetchDashboard");
    if (response == 100) {
      var realData = jsonData["response_data"]["deals"];
      // print(realData);
      for (var u in realData) {
        Dashboard dashboard = Dashboard(
            id: u["id"],
            exactLegalCompanyName: u["exact_legal_company_name"],
            c: DateTime.parse(u["c"]),
            leadStatus: u["lead_status"],
            phone: u["phone"],
            opportunityStatus: u["opportunity_status"],
            sendToCrmDate: u["send_to_crm_date"],
            offerSentDate: u["offer_sent_date"],
            contractInDate: u["contract_in_date"],
            contractOutDate: u["contract_out_date"],
            fundedDate: u["funded_date"]);
        setState(() {
          loading = false;
          dashboardDetails.add(dashboard);
        });
      }
      if (dashboardDetails.isEmpty) {
        setState(() {
          loading = false;
        });
      }
      currentPage++;
      return true;
    } else {
      setVisitingFlag();
      Fluttertoast.showToast(
        msg: "Session Expired, Please Login Again",
        textColor: Colors.white,
        backgroundColor: Colors.grey,
      );
      Navigator.pushReplacementNamed(context, "login");
      return false;
    }
  }

  //FUNCTION TO FETCH DASHBOARD//

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

  //DEBOUNCE FUNCTION FOR SEARCHING//
  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with query
      setState(() {
        setState(() {
          keyword = query;
          currentPage = 1;
          loading = true;
        });
        dashboardDetails.clear();
        fetchDashBoard();
      });
    });
  }
  //DEBOUNCE FUNCTION FOR SEARCHING//

  //Logout//
  setVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("isoToken", "");
    preferences.setString("isoLog", "logged out");
    preferences.setString("isoName", "");
  }
  //Logout//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
    fetchDashBoard();
    //removed for testing
    // sendFCMToken();
    print("token${Provider.of<Data>(context, listen: false).token}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(selectedFromDate);
    Size _size = MediaQuery.of(context).size;
    setState(() {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    });
    if (screenHeight != null) {
      if (screenHeight! > 1000) {
        setState(() {
          tab = true;
        });
      } else {
        setState(() {
          phone = true;
        });
      }
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        //DRAWER START//
        drawer: Container(
            width: _size.width > 650 ? _size.width / 2 : null,
            child: IsoDrawer(
              onClickHome: () {
                setState(() {
                  Provider.of<Data>(context, listen: false).pageNumber = 1;
                });
                Navigator.pop(context);
              },
              onClickProfile: () {
                setState(() {
                  Provider.of<Data>(context, listen: false).pageNumber = 3;
                });
                Navigator.pop(context);
              },
              onClickNotification: () {
                setState(() {
                  Provider.of<Data>(context, listen: false).pageNumber = 2;
                });
                Navigator.pop(context);
              },
              onClickLogout: () {
                Navigator.pop(context);
                showBottomSheet();
              },
            )),
        //DRAWER END//

        //BOTTOM NAVIGATION//
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height / 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: homeBoxShadow,
                offset: Offset(0.0, -1),
                blurRadius: 7,
              )
            ],
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 35, right: 35, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
//                    Provider.of<Data>(context,listen: false). homeScreen=true;
//                    Provider.of<Data>(context,listen: false). profileScreen=false;
//                    Provider.of<Data>(context,listen: false).notificationScreen=false;
                      Provider.of<Data>(context, listen: false).pageNumber = 1;
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 20,
                    width: MediaQuery.of(context).size.width / 10,
//                  height: phone?MediaQuery.of(context).size.height / 25:MediaQuery.of(context).size.height / 40,
//                  width: phone?MediaQuery.of(context).size.width / 15:MediaQuery.of(context).size.width/25,
//              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/6.38),
                    child: Image.asset(
                        Provider.of<Data>(context, listen: false).pageNumber ==
                                1
                            ? "images/selectedHome.png"
                            : "images/Home.png",
                        fit: phone ? BoxFit.none : BoxFit.fill),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
//                    Provider.of<Data>(context,listen: false). profileScreen=false;
//                    Provider.of<Data>(context,listen: false). homeScreen=false;
//                    Provider.of<Data>(context,listen: false). notificationScreen=true;
                      Provider.of<Data>(context, listen: false).pageNumber = 2;
                    });
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 10,
                      child: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Image.asset(
                              Provider.of<Data>(context, listen: false)
                                          .pageNumber ==
                                      2
                                  ? "images/selectedNotification.png"
                                  : "images/notificationIcon.png",
                              fit: phone ? BoxFit.none : BoxFit.fill))),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
//                    Provider.of<Data>(context,listen: false). profileScreen=true;
//                    Provider.of<Data>(context,listen: false).homeScreen=false;
//                    Provider.of<Data>(context,listen: false).notificationScreen=false;
                      Provider.of<Data>(context, listen: false).pageNumber = 3;
                    });
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 10,
//              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/5 ),
                      child: Image.asset(
                        Provider.of<Data>(context, listen: false).pageNumber ==
                                3
                            ? "images/selectedProfile.png"
                            : "images/myprofile.png",
                        fit: phone ? BoxFit.none : BoxFit.fill,
                      )),
                ),
              ],
            ),
          ),
        ),
        //BOTTOM NAVIGATION//

        //FLOATING ACTION BUTTON START//
        floatingActionButton:
            Provider.of<Data>(context, listen: false).pageNumber == 1 &&
                    searchIconPressed == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.15,
                        height: MediaQuery.of(context).size.height / 20.25,
                        margin: EdgeInsets.only(
                            left: phone
                                ? MediaQuery.of(context).size.width / 13
                                : MediaQuery.of(context).size.width / 18),
                        child: Roundedbutton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, 'upload');
                          },
                          color: fabColor,
                          text: "New Upload",
                          fontSize: MediaQuery.of(context).size.height / 54,
                        ),
                      ),
                    ],
                  )
                : Container(),
        //FLOATING ACTION BUTTON END//

        body: Provider.of<Data>(context, listen: false).pageNumber == 1
            ? Builder(
                builder: (context) => Scaffold(
                      body: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(unusedFocusNode);
                        },
                        child: Container(
                          height: double.infinity,
                          color: Colors.white,
                          child: Container(
                            child: SafeArea(
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                47.6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    15),
                                            child: Image.asset(
                                                "images/drawerIcon.png"),
                                          ),
                                        ),
                                        Container(
                                          child: Image.asset(
                                            "images/isologo.png",
                                            fit: BoxFit.contain,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17.0,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              16.66,
                                          child: searchIconPressed
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      searchIconPressed =
                                                          !searchIconPressed;
                                                      currentPage = 1;
                                                      selectedFromDate = null;
                                                      selectedToDate = null;
                                                      keyword = "";
                                                      firstToDate =
                                                          DateTime(2015, 8);
                                                      loading = true;
                                                      controller.clear();
                                                    });
                                                    dashboardDetails.clear();
                                                    fetchDashBoard();
                                                  },
                                                  child: Image.asset(
                                                      "images/close.png"))
                                              : GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      searchIconPressed =
                                                          !searchIconPressed;
                                                    });
                                                  },
                                                  child: Image.asset(
                                                      "images/searchIcon.png")),
                                        ),
                                      ],
                                    ),
                                  ),

                                  searchIconPressed
                                      ?
                                      //SEARCH BAR//
                                      Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.15,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  23,
                                              margin: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      54),
                                              decoration:
                                                  BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    color: textFieldShadow
                                                        .withOpacity(1),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 3))
                                              ]),
                                              child: TextField(
                                                controller: controller,
                                                style: TextStyle(
                                                    color: hintTextColor,
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            81),
                                                decoration:
                                                    kuserInputButtons.copyWith(
                                                        hintText:
                                                            "Search keyword here...",
                                                        prefixIcon: Container(
                                                          child: Image.asset(
                                                              'images/searchIcon.png'),
                                                        ),
                                                        suffixIcon:
                                                            GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    filterIconPressed =
                                                                        true;
                                                                  });
                                                                },
                                                                child: Container(
                                                                    child: Image
                                                                        .asset(
                                                                            "images/filterIcon.png")))),
                                                cursorColor: hintTextColor,
                                                onChanged: _onSearchChanged,
                                              ),
                                            ),
                                            filterIconPressed
                                                ? Column(
                                                    children: [
                                                      //DATE FILTERS START//
                                                      Row(
                                                        children: [
                                                          DateWidget(
                                                            leftMargin:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    15,
                                                            text: selectedFromDate !=
                                                                    null
                                                                ? selectedFromDate
                                                                : empty,
                                                            onTapIOS: () {
                                                              _selectFromDateIOS(
                                                                  context);
                                                            },
                                                            onTap: () {
                                                              _selectFromDate(
                                                                  context);
                                                            },
                                                            hintText:
                                                                "From Date",
                                                          ),
                                                          DateWidget(
                                                              leftMargin:
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      28.8,
                                                              hintText:
                                                                  "To Date",
                                                              onTap: () {
                                                                _selectToDate(
                                                                    context);
                                                              },
                                                              onTapIOS: () {
                                                                _selectToDateIOS(
                                                                    context);
                                                              },
                                                              text:
                                                                  selectedToDate)
                                                        ],
                                                      ),
                                                      //DATE FILTERS END//
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2.4,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                23,
                                                            margin: EdgeInsets.only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    54,
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    15),
                                                            child:
                                                                RoundedButtonForSearch(
                                                              onPressed: () {
                                                                setState(() {
                                                                  currentPage =
                                                                      1;
                                                                  selectedFromDate =
                                                                      null;
                                                                  selectedToDate =
                                                                      null;
                                                                  keyword = "";
                                                                  firstToDate =
                                                                      DateTime(
                                                                          2015,
                                                                          8);
                                                                  loading =
                                                                      true;
                                                                  controller
                                                                      .clear();
                                                                });
                                                                dashboardDetails
                                                                    .clear();
                                                                fetchDashBoard();
                                                              },
                                                              color:
                                                                  clearButton,
                                                              text: "Clear",
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  67.5,
                                                              textColor:
                                                                  clearText,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2.4,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                23,
                                                            margin: EdgeInsets.only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    54,
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    28.8),
                                                            child:
                                                                RoundedButtonForSearch(
                                                              onPressed: () {
                                                                setState(() {
                                                                  currentPage =
                                                                      1;
                                                                  loading =
                                                                      true;
                                                                });
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        unusedFocusNode);
                                                                dashboardDetails
                                                                    .clear();
                                                                fetchDashBoard();
                                                              },
                                                              color:
                                                                  buttonColor,
                                                              text: "Apply",
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  67.5,
                                                              textColor:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      //SEARCH BAR //
                                      :

                                      // BOXES//
                                      Container(
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  33.75),
                                          child: Row(
                                            children: [
                                              HomeScreenDisplayBox(
                                                amount: currencyConverter(
                                                    Provider.of<Data>(context,
                                                                listen: false)
                                                            .totalFunding ??
                                                        0),
                                                title:
                                                    "Total Funding for the Month",
                                              ),
                                              HomeScreenDisplayBox(
                                                amount: "\$" +
                                                    currencyConverter(Provider
                                                                .of<
                                                                        Data>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .totalFundingAmount ??
                                                        0),
                                                title: "Total Revenue Funded",
                                              ),
                                              HomeScreenDisplayBox(
                                                amount: "\$" +
                                                    currencyConverter(
                                                        Provider.of<Data>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .totalRevenue ??
                                                            0),
                                                title: "Total Revenue Earned",
                                              )
                                            ],
                                          ),
                                        ),
                                  //BOXES//
                                  loading
                                      ? Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor: fabColor,
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : dashboardDetails.isNotEmpty
                                          ? Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        27),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  16),
                                                          topRight:
                                                              Radius.circular(
                                                                  16)),
                                                  color: homeBoxColor,
                                                ),
                                                child: SmartRefresher(
                                                  controller: refreshController,
                                                  enablePullUp: true,
                                                  onRefresh: () async {
                                                    setState(() {
                                                      dashboardDetails.clear();
                                                      loading = true;
                                                    });

                                                    final result =
                                                        await fetchDashBoard(
                                                            isRefresh: true);
                                                    if (result) {
                                                      refreshController
                                                          .refreshCompleted();
                                                    } else {
                                                      refreshController
                                                          .refreshFailed();
                                                    }
                                                  },
                                                  onLoading: () async {
                                                    final result =
                                                        await fetchDashBoard();
                                                    if (result) {
                                                      refreshController
                                                          .loadComplete();
                                                    } else {
                                                      refreshController
                                                          .loadFailed();
                                                    }
                                                  },
                                                  child: ListView.builder(
                                                      physics:
                                                          ClampingScrollPhysics(),
                                                      padding: EdgeInsets.only(
                                                          bottom: 20),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          dashboardDetails
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dealId = dashboardDetails[
                                                                          index]
                                                                      .id ??
                                                                  '';
                                                              Provider.of<Data>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .dealCreated =
                                                                  dashboardDetails[
                                                                          index]
                                                                      .c;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dealCompanyName = dashboardDetails[
                                                                          index]
                                                                      .exactLegalCompanyName ??
                                                                  '';
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dealNumber = dashboardDetails[
                                                                          index]
                                                                      .phone ??
                                                                  '';
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dealOpportunityStatus = dashboardDetails[
                                                                          index]
                                                                      .opportunityStatus ??
                                                                  '';
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .sendToCrmDate = dashboardDetails[
                                                                              index]
                                                                          .sendToCrmDate !=
                                                                      null
                                                                  ? DateTime.parse(
                                                                      dashboardDetails[index]
                                                                              .sendToCrmDate ??
                                                                          '')
                                                                  : empty;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .offerSendDate = dashboardDetails[
                                                                              index]
                                                                          .offerSentDate !=
                                                                      null
                                                                  ? DateTime.parse(
                                                                      dashboardDetails[index]
                                                                              .offerSentDate ??
                                                                          '')
                                                                  : empty;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .contractInDate = dashboardDetails[
                                                                              index]
                                                                          .contractInDate !=
                                                                      null
                                                                  ? DateTime.parse(
                                                                      dashboardDetails[index]
                                                                              .contractInDate ??
                                                                          '')
                                                                  : empty;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .contractOutDate = dashboardDetails[
                                                                              index]
                                                                          .contractOutDate !=
                                                                      null
                                                                  ? DateTime.parse(
                                                                      dashboardDetails[index]
                                                                              .contractOutDate ??
                                                                          '')
                                                                  : empty;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .fundedDate = dashboardDetails[
                                                                              index]
                                                                          .fundedDate !=
                                                                      null
                                                                  ? DateTime.parse(
                                                                      dashboardDetails[index]
                                                                              .fundedDate ??
                                                                          '')
                                                                  : empty;
                                                              Provider.of<Data>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dealStatus = dashboardDetails[
                                                                          index]
                                                                      .leadStatus ??
                                                                  '';
                                                            });
                                                            Navigator
                                                                .pushReplacementNamed(
                                                                    context,
                                                                    'detailed');
                                                          },
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                7.04,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                1.15,
                                                            margin: EdgeInsets.only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    26.13,
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    15,
                                                                right: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    15),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            16)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: textFieldShadow
                                                                          .withOpacity(
                                                                              1),
                                                                      blurRadius:
                                                                          10,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              3)),
                                                                ]),
                                                            child: Container(
                                                              margin: EdgeInsets.only(
                                                                  left: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      18.75),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            1.5,
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                MediaQuery.of(context).size.height / 54),
                                                                        child:
                                                                            Text(
                                                                          dashboardDetails[index].exactLegalCompanyName ??
                                                                              '',
                                                                          style: TextStyle(
                                                                              fontFamily: "Quicksand",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: homeClientName,
                                                                              fontSize: MediaQuery.of(context).size.height / 57.85),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            placeCall("tel:${dashboardDetails[index].phone}");
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: MediaQuery.of(context).size.height / 54,
                                                                              right: MediaQuery.of(context).size.width / 26.8),
                                                                          child:
                                                                              Image.asset('images/telephone.png'),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      "${dashboardDetails[index].c?.month}-${dashboardDetails[index].c?.day}-${dashboardDetails[index].c?.year}",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "Quicksand",
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              hintTextColor,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.height / 81),
                                                                    ),
                                                                  ),
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets.only(
                                                                          top: MediaQuery.of(context).size.height /
                                                                              90),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                1,
                                                                            circleTitle:
                                                                                "Docs in",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "docs_in"
                                                                                ? docsInColor
                                                                                : homeCircleUnfilled,
                                                                            textColor: dashboardDetails[index].leadStatus == "docs_in"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
                                                                            circleBorder: dashboardDetails[index].leadStatus == "docs_in"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                2,
                                                                            circleTitle:
                                                                                "Submitted",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "submitted"
                                                                                ? submittedColor
                                                                                : homeCircleUnfilled,
//
                                                                            textColor: dashboardDetails[index].leadStatus == "submitted"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//
                                                                            circleBorder: dashboardDetails[index].leadStatus == "submitted"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                3,
                                                                            circleTitle:
                                                                                "Approved",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "approved"
                                                                                ? approvedColor
                                                                                : homeCircleUnfilled,
//
                                                                            textColor: dashboardDetails[index].leadStatus == "approved"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//
                                                                            circleBorder: dashboardDetails[index].leadStatus == "approved"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                4,
                                                                            circleTitle:
                                                                                "Contract out",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "contract_out"
                                                                                ? contractOutColor
                                                                                : homeCircleUnfilled,
//

                                                                            textColor: dashboardDetails[index].leadStatus == "contract_out"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//

                                                                            circleBorder: dashboardDetails[index].leadStatus == "contract_out"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                5,
                                                                            circleTitle:
                                                                                "Contract in",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "contract_in"
                                                                                ? contractInColor
                                                                                : homeCircleUnfilled,
//

                                                                            textColor: dashboardDetails[index].leadStatus == "contract_in"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//

                                                                            circleBorder: dashboardDetails[index].leadStatus == "contract_in"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                6,
                                                                            circleTitle:
                                                                                "Funded",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "funded"
                                                                                ? fundedColor
                                                                                : homeCircleUnfilled,
//

                                                                            textColor: dashboardDetails[index].leadStatus == "funded"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//

                                                                            circleBorder: dashboardDetails[index].leadStatus == "funded"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                          DottedSeparator(),
                                                                          HomeScreenCircle(
                                                                            number:
                                                                                7,
                                                                            circleTitle:
                                                                                "Declined",
                                                                            circleBackground: dashboardDetails[index].leadStatus == "declined"
                                                                                ? Colors.black
                                                                                : homeCircleUnfilled,
//

                                                                            textColor: dashboardDetails[index].leadStatus == "declined"
                                                                                ? Colors.white
                                                                                : homeCircleUnfilledText,
//

                                                                            circleBorder: dashboardDetails[index].leadStatus == "declined"
                                                                                ? homeCircleBorder
                                                                                : homeCircleUnfilledBorder,
//
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              child: Center(
                                                child: Text(
                                                    "No items to display",
                                                    style: TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: homeClientName,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            57.85)),
                                              ),
                                            )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
            : Provider.of<Data>(context, listen: false).pageNumber == 3
                ? ProfilePage()
                : Provider.of<Data>(context, listen: false).pageNumber == 2
                    ? NotificationPage(
                        onClose: () {
                          setState(() {
//          Provider.of<Data>(context,listen: false).homeScreen=true;
//          Provider.of<Data>(context,listen: false).profileScreen=false;
//          Provider.of<Data>(context,listen: false).notificationScreen=false;
                            Provider.of<Data>(context, listen: false)
                                .pageNumber = 1;
                          });
                        },
                      )
                    : Container(),
      ),
    );
  }
}

class Dashboard {
  final String? id;
  final String? exactLegalCompanyName;
  final String? phone;
  final DateTime? c;
  final String? leadStatus;
  final String? opportunityStatus;
  final String? sendToCrmDate;
  final String? offerSentDate;
  final String? contractOutDate;
  final String? contractInDate;
  final String? fundedDate;

  Dashboard(
      {this.phone,
      this.id,
      this.c,
      this.exactLegalCompanyName,
      this.leadStatus,
      this.opportunityStatus,
      this.contractInDate,
      this.contractOutDate,
      this.offerSentDate,
      this.sendToCrmDate,
      this.fundedDate});
}
