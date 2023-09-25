import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'dart:convert';

import 'package:iso/services/apiEndPoints.dart';

import 'package:iso/widgets/detail_floatingButton.dart';
import 'package:iso/widgets/detailed_telephone.dart';
import 'package:iso/widgets/dottedLine_vertcal.dart';
import 'package:iso/widgets/notication_widget.dart';
import 'package:iso/widgets/offerButton.dart';
import 'package:iso/widgets/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailedPage extends StatefulWidget {
  @override
  _DetailedPageState createState() => _DetailedPageState();
}

class _DetailedPageState extends State<DetailedPage> {
  List pendingDocuments = [];
  List<Notes> fetchedNotes = [];
  List<UploadedDocuments> documentsUploaded = [];
  String offerStatus = "";
  String offerText = "Loading ...";
  String query = "";
  List<Query> queryNotes = [];
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

  getUnderWritingStatus() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "method": "get_uw_checklist",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId
    });
    var jsonData = jsonDecode(data.body);
    print("underwriting$jsonData");
    var statusCode = jsonData["response_code"];
    if (statusCode == 100) {
      var realData = jsonData["response_data"]["data"]["pending_stips"];
      setState(() {
        pendingDocuments = realData;
      });
    }
  }

  //FUNCTION TO FETCH NOTES//
  Future<List<Notes>> fetchNotes() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "method": "fetch_notes",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId
    });
    var jsonData = jsonDecode(data.body);
    var statusCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["data"];
    if (statusCode == 100) {
      for (var u in realData) {
        Notes notes =
            Notes(notes: u["notes"], created: DateTime.parse(u["created"]));
        setState(() {
          fetchedNotes.add(notes);
        });
      }
    }
    return fetchedNotes;
  }
  //Fetch NOTES//

  //FUNCTION TO FETCH UPLOADED DOCUMENTS//
  Future<List<UploadedDocuments>> getUploadedDocuments() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "method": "get_uploaded_documents"
    });
    var jsonData = jsonDecode(data.body);
    var statusCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["data"];
    print("called$realData");
    if (statusCode == 100) {
      for (var u in realData) {
        UploadedDocuments uploadedDocuments = UploadedDocuments(
            title: u["title"],
            created: DateTime.parse(u["created"]),
            filePath: u["file_path"]);
        setState(() {
          documentsUploaded.add(uploadedDocuments);
        });
      }
    }
    return documentsUploaded;
  }
  //FUNCTION TO FETCH UPLOADED DOCUMENTS//

  //FUNCTION TO SEND TO MARKET PLACE//
  sendToMarketPlace() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "method": "send_to_market_place"
    });
    var jsonData = jsonDecode(data.body);
    var responseCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["errors"];

    if (responseCode == 100) {
      Fluttertoast.showToast(
          msg: "Your deal has been send to the marketplace",
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          gravity: ToastGravity.CENTER);
    } else {
      Fluttertoast.showToast(
          msg: "$realData",
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG);
      print(realData);
    }
  }
  //FUNCTION TO SEND TO MARKET PLACE//

  //FUNCTION TO FETCH OFFERS //
  fetchOffer() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "method": "lead_view"
    });
    var jsonData = jsonDecode(data.body);
    var responseCode = jsonData["response_code"];
    var realOfferLink = jsonData["response_data"]["data"]["offer_link"];
    var realOfferStatus = jsonData["response_data"]["data"]["offer_status"];
    print("json$jsonData");
    print("offerlink$realOfferLink");
    print("offer status$realOfferStatus");

    if (responseCode == 100) {
      setState(() {
        offerStatus = realOfferStatus;
        Provider.of<Data>(context, listen: false).offerUrl = realOfferLink;
      });
      if (realOfferStatus == "pending") {
        setState(() {
          offerText = "Merchant Offer";
        });
      } else {
        setState(() {
          offerText = "No Offers Available";
        });
      }
    }
  }
  //FUNCTION TO FETCH OFFERS//

  //FUNCTION TO SUBMIT QUERY//
  void submitQuery() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "method": "submit_query",
      "notes": query
    });
    var jsonData = jsonDecode(data.body);
    var responseCode = jsonData["response_code"];
    if (responseCode == 100) {
      setState(() {
        query = "";
      });
      queryNotes.clear();

      fetchQuery();
    }
  }
  //FUNCTION TO SUBMIT QUERY//

  //FUNCTION TO FETCH QUERY//
  Future<List<Query>> fetchQuery() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "method": "fetch_query"
    });
    var jsonData = jsonDecode(data.body);
    print("query$jsonData");
    var statusCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["data"];
    print("called again");
    if (statusCode == 100) {
      for (var u in realData) {
        Query queryData = Query(notes: u["notes"], createdAt: u["created_at"]);
        setState(() {
          queryNotes.add(queryData);
        });
      }
    }
    return queryNotes;
  }

  //SHOW BOTTOM SHEET//
  showBottomSheetQuery() {
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
                          child: Text("Submit Question Below",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height /
                                      47.65,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Quicksand",
                                  color: uploadDocumentsTitle)),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.12,
                          height: MediaQuery.of(context).size.height / 8,
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 45),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              border: Border.all(
                                  color: Colors.grey,
                                  width: MediaQuery.of(context).size.height /
                                      926)),
                          child: TextField(
                            style: TextStyle(
                                color: uploadDocumentsTitle,
                                fontFamily: "Open",
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.height / 54),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, right: 15, top: 15, bottom: 15),
                            ),
                            cursorColor: Colors.black,
                            maxLines: 100,
                            onChanged: (value) {
                              setState(() {
                                query = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.15,
                          height: MediaQuery.of(context).size.height / 20.25,
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 45,
                              bottom: 20),
                          child: Roundedbutton(
                            onPressed: () {
                              if (query.length == 0) {
                                print("no query");
                              } else {
                                Navigator.pop(context);
                                submitQuery();
                              }
                            },
                            color: fabColor,
                            text: "Submit",
                            fontSize: MediaQuery.of(context).size.height / 54,
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
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    getUnderWritingStatus();
    fetchNotes();
    getUploadedDocuments();
    fetchQuery();
    fetchOffer();
    print("DEAL ID ${Provider.of<Data>(context, listen: false).dealId}");
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: GestureDetector(
            onTap: () {
              showBottomSheetQuery();
            },
            child: FloatingButtonContainer()),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    height: 500,
                    color: profileScreenBackground,
                  ),
                  Positioned(
                    left: _size.width > 650
                        ? _size.width / 3
                        : MediaQuery.of(context).size.width / 2.5,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 20),
                      child: CircleAvatar(
                        radius: _size.width > 650
                            ? _size.height / 2.5
                            : MediaQuery.of(context).size.height / 5,
                        backgroundColor: profileScreenCircle,
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, 'home');
                          },
                          child: Container(
                            height: _size.height / 30,
                            width: _size.width / 10,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 10,
                                left: MediaQuery.of(context).size.width / 15),
                            child: Image.asset('images/backArrow.png',
                                fit: _size.width > 650
                                    ? BoxFit.fill
                                    : BoxFit.none),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: _size.height / 20,
                              right: _size.width / 15.6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: _size.height / 15),
                                child: Text(
                                  Provider.of<Data>(context, listen: false)
                                      .dealCompanyName,
                                  style: TextStyle(
                                      fontSize: _size.height / 47.65,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Quicksand",
                                      color: Colors.white),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: Text("Created  ",
                                        style: TextStyle(
                                            fontSize: _size.height / 67.5,
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  ),
                                  Container(
                                    child: Text(
                                        "${Provider.of<Data>(context, listen: false).dealCreated?.month}-${Provider.of<Data>(context, listen: false).dealCreated?.day}-${Provider.of<Data>(context, listen: false).dealCreated?.year}",
                                        style: TextStyle(
                                            fontSize: _size.height / 67.5,
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: homeBoxShadow, width: 1),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)),
                      color: Colors.white,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: _size.height / 27.9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: MediaQuery.of(context).size.height / 20.25,
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width / 13,
                                bottom: 20),
                            child: OfferButton(
                              onPressed: () {
                                offerText == "Merchant Offer"
                                    ? Navigator.pushNamed(context, "offerPage")
                                    : print("no offer");
                              },
                              color: offerText == "Merchant Offer"
                                  ? fabColor
                                  : Color(0xffe5f0f4),
                              text: offerText,
                              textColor: offerText == "Merchant Offer"
                                  ? Colors.white
                                  : profilePageHeading,
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                placeCall(
                                    "tel:${Provider.of<Data>(context, listen: false).dealNumber}");
                              },
                              child: DetailedTelephone(
                                number:
                                    Provider.of<Data>(context, listen: false)
                                        .dealNumber,
                              )),
                          NotificationWidget(
                            heading: "Send to Marketplace",
                            subHeading: Provider.of<Data>(context,
                                            listen: false)
                                        .sendToCrmDate !=
                                    null
                                ? "${Provider.of<Data>(context, listen: false).sendToCrmDate?.month}-${Provider.of<Data>(context, listen: false).sendToCrmDate?.day}-${Provider.of<Data>(context, listen: false).sendToCrmDate?.year}"
                                : "",
                            onColor: Provider.of<Data>(context, listen: false)
                                        .dealOpportunityStatus ==
                                    "send_to_crm"
                                ? userNotificationOrange
                                : Provider.of<Data>(context, listen: false)
                                            .dealOpportunityStatus ==
                                        "offer_sent"
                                    ? userNotificationOrange
                                    : Provider.of<Data>(context, listen: false)
                                                .dealOpportunityStatus ==
                                            "contract_out"
                                        ? userNotificationOrange
                                        : Provider.of<Data>(context,
                                                        listen: false)
                                                    .dealOpportunityStatus ==
                                                "contract_in"
                                            ? userNotificationOrange
                                            : Provider.of<Data>(context,
                                                            listen: false)
                                                        .dealOpportunityStatus ==
                                                    "funded"
                                                ? userNotificationOrange
                                                : homeCircleUnfilled,
                            top: _size.height / 40.5,
                          ),
                          DottedLineVertical(),
                          NotificationWidget(
                            heading: "Offer Sent",
                            subHeading: Provider.of<Data>(context,
                                            listen: false)
                                        .offerSendDate !=
                                    null
                                ? "${Provider.of<Data>(context, listen: false).offerSendDate?.month}-${Provider.of<Data>(context, listen: false).offerSendDate?.day}-${Provider.of<Data>(context, listen: false).offerSendDate?.year}"
                                : "",
                            onColor: Provider.of<Data>(context, listen: false)
                                        .dealOpportunityStatus ==
                                    "contract_out"
                                ? userNotificationOrange
                                : Provider.of<Data>(context, listen: false)
                                            .dealOpportunityStatus ==
                                        "offer_sent"
                                    ? userNotificationOrange
                                    : Provider.of<Data>(context, listen: false)
                                                .dealOpportunityStatus ==
                                            "contract_in"
                                        ? userNotificationOrange
                                        : Provider.of<Data>(context,
                                                        listen: false)
                                                    .dealOpportunityStatus ==
                                                "funded"
                                            ? userNotificationOrange
                                            : homeCircleUnfilled,
                            top: 0,
                          ),
                          DottedLineVertical(),
                          NotificationWidget(
                            heading: "Contract Out",
                            subHeading: Provider.of<Data>(context,
                                            listen: false)
                                        .contractOutDate !=
                                    null
                                ? "${Provider.of<Data>(context, listen: false).contractOutDate?.month}-${Provider.of<Data>(context, listen: false).contractOutDate?.day}-${Provider.of<Data>(context, listen: false).contractOutDate?.year}"
                                : "",
                            onColor: Provider.of<Data>(context, listen: false)
                                        .dealOpportunityStatus ==
                                    "contract_out"
                                ? userNotificationOrange
                                : Provider.of<Data>(context, listen: false)
                                            .dealOpportunityStatus ==
                                        "contract_in"
                                    ? userNotificationOrange
                                    : Provider.of<Data>(context, listen: false)
                                                .dealOpportunityStatus ==
                                            "funded"
                                        ? userNotificationOrange
                                        : homeCircleUnfilled,
                            top: 0,
                          ),
                          DottedLineVertical(),
                          NotificationWidget(
                            heading: "Contract In",
                            subHeading: Provider.of<Data>(context,
                                            listen: false)
                                        .contractInDate !=
                                    null
                                ? "${Provider.of<Data>(context, listen: false).contractInDate?.month}-${Provider.of<Data>(context, listen: false).contractInDate?.day}-${Provider.of<Data>(context, listen: false).contractInDate?.year}"
                                : "",
                            onColor: Provider.of<Data>(context, listen: false)
                                        .dealOpportunityStatus ==
                                    "contract_in"
                                ? userNotificationOrange
                                : Provider.of<Data>(context, listen: false)
                                            .dealOpportunityStatus ==
                                        "funded"
                                    ? userNotificationOrange
                                    : homeCircleUnfilled,
                            top: 0,
                          ),
                          DottedLineVertical(),
                          NotificationWidget(
                            heading: "Funded",
                            subHeading: Provider.of<Data>(context,
                                            listen: false)
                                        .fundedDate !=
                                    null
                                ? "${Provider.of<Data>(context, listen: false).fundedDate?.month}-${Provider.of<Data>(context, listen: false).fundedDate?.day}-${Provider.of<Data>(context, listen: false).fundedDate?.year}"
                                : "",
                            onColor: Provider.of<Data>(context, listen: false)
                                        .dealOpportunityStatus ==
                                    "funded"
                                ? userNotificationOrange
                                : homeCircleUnfilled,
                            top: 0,
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width / 1.15,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 22.82,
                                left: _size.width / 14.7),
                            color: lineColor,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 39.5,
                                left: MediaQuery.of(context).size.width / 15),
                            child: Text("Underwriting Status Checklist",
                                style: TextStyle(
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.bold,
                                    color: profilePageHeading,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            54)),
                          ),
                          //UNDERWRITING STATUS CHECKLIST BOX//
                          ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: pendingDocuments.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height:
                                      MediaQuery.of(context).size.height / 16.2,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          36.8,
                                      left: _size.width > 650
                                          ? _size.width / 15
                                          : _size.width / 15,
                                      right: _size.width > 650
                                          ? _size.width / 15
                                          : _size.width / 15),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: documentListBoxBorder,
                                          width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      color: documentListBox,
                                      boxShadow: [
                                        BoxShadow(
                                            color: documentListBoxShadow
                                                .withOpacity(1),
                                            blurRadius: 20,
                                            offset: Offset(0, 0))
                                      ]),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              14.72,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.33,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: _size.width > 650
                                                    ? _size.height / 35
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        30.5,
                                                width: _size.width > 650
                                                    ? _size.width / 25
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        17.85,
                                                margin: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        23.44),
                                                child: Image.asset(
                                                  'images/crossIcon.png',
                                                  fit: _size.width > 650
                                                      ? BoxFit.fill
                                                      : BoxFit.none,
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        31.25),
                                                child: Text(
                                                    pendingDocuments[index] ==
                                                            "fcs"
                                                        ? "FCS Document"
                                                        : pendingDocuments[
                                                                    index] ==
                                                                "pipl"
                                                            ? "People Information"
                                                            : pendingDocuments[
                                                                        index] ==
                                                                    "competing_offer"
                                                                ? "Competing Offer"
                                                                : pendingDocuments[
                                                                            index] ==
                                                                        "credit_report"
                                                                    ? "Credit Report"
                                                                    : pendingDocuments[index] ==
                                                                            "driving_license"
                                                                        ? "Driving License"
                                                                        : pendingDocuments[index] ==
                                                                                "hello_sign_document"
                                                                            ? "HelloSign Document"
                                                                            : pendingDocuments[index] ==
                                                                                    "lease"
                                                                                ? "Lease"
                                                                                : pendingDocuments[index] ==
                                                                                        "other"
                                                                                    ? "Other"
                                                                                    : pendingDocuments[index] ==
                                                                                            "signed_application"
                                                                                        ? "Signed Application"
                                                                                        : pendingDocuments[index] ==
                                                                                                "esign_document"
                                                                                            ? "Signed Contract"
                                                                                            : pendingDocuments[index] ==
                                                                                                    "unsigned_document"
                                                                                                ? "Unsigned Contract"
                                                                                                : pendingDocuments[index] ==
                                                                                                        "voided_check"
                                                                                                    ? "Voided Check"
                                                                                                    : "",
                                                    style: TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: homeAmountColor,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            67.5)),
                                              )
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: documentListBoxBorder,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            color: Colors.white,
                                          )),
                                      Container(
                                        height: _size.width > 650
                                            ? _size.height / 35
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                32.4,
                                        width: _size.width > 650
                                            ? _size.width / 25
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                        margin: EdgeInsets.only(
                                            left: _size.width > 650
                                                ? _size.width / 30
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    53.57),
                                        child: Image.asset(
                                          'images/uploadSmallIcon.png',
                                          fit: _size.width > 650
                                              ? BoxFit.fill
                                              : BoxFit.none,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                          //UNDERWRITING STATUS CHECKLIST BOX//

                          //UPDATES BOX//
                          Container(
                            height: _size.height / 12.65,
                            width: _size.width / 1.15,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 36.8,
                                left: _size.width > 650
                                    ? _size.width / 15
                                    : _size.width / 15),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: documentListBoxBorder, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                color: updateBoxColor,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          documentListBoxShadow.withOpacity(1),
                                      blurRadius: 20,
                                      offset: Offset(0, 0))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          62.3),
                                  child: Text("Updates",
                                      style: TextStyle(
                                          fontFamily: "Quicksand",
                                          fontWeight: FontWeight.bold,
                                          color: NotificationHeading,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              54)),
                                ),
                                Container(
                                  child: Text("No notes available",
                                      style: TextStyle(
                                          fontFamily: "Quicksand",
                                          fontWeight: FontWeight.w400,
                                          color: NotificationSubHeading,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              67.5)),
                                )
                              ],
                            ),
                          ),
                          //UPDATE BOX END//
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width / 1.15,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 22.82,
                                left: _size.width / 14.7),
                            color: lineColor,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 39.5,
                                left: MediaQuery.of(context).size.width / 15),
                            child: Text("Documents Uploaded",
                                style: TextStyle(
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.bold,
                                    color: profilePageHeading,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            54)),
                          ),
                          //UPLOADED DOCUMENTS LIST //
                          ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: documentsUploaded.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height:
                                      MediaQuery.of(context).size.height / 16.2,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          36.8,
                                      left: _size.width > 650
                                          ? _size.width / 15
                                          : _size.width / 15,
                                      right: _size.width > 650
                                          ? _size.width / 15
                                          : _size.width / 15),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: documentListBoxBorder,
                                          width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      color: documentListBox,
                                      boxShadow: [
                                        BoxShadow(
                                            color: documentListBoxShadow
                                                .withOpacity(1),
                                            blurRadius: 20,
                                            offset: Offset(0, 0))
                                      ]),
                                  child: Row(
                                    children: [
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              14.72,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.33,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    38.57,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    17.85,
                                                margin: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        23.44),
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: Container(
                                                    height: _size.width > 650
                                                        ? _size.height / 35
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            30.5,
                                                    width: _size.width > 650
                                                        ? _size.width / 25
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            17.85,
                                                    child: Image.asset(
                                                      'images/greenTick.png',
                                                      fit: _size.width > 650
                                                          ? BoxFit.fill
                                                          : BoxFit.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            31.25,
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            95),
                                                    child: Text(
                                                        documentsUploaded[index]
                                                                .title ??
                                                            '',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Quicksand",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                documentsUploadListTitle,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                67.5)),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            31.25),
                                                    child: Text(
                                                        "${documentsUploaded[index].created?.month}-${documentsUploaded[index].created?.day}-${documentsUploaded[index].created?.year}",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Quicksand",
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                homeAmountColor,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                81)),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: documentListBoxBorder,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            color: Colors.white,
                                          )),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            Provider.of<Data>(context,
                                                        listen: false)
                                                    .viewDocUrl =
                                                documentsUploaded[index]
                                                        .filePath ??
                                                    '';
                                          });
                                          Navigator.pushNamed(context, "view");
                                        },
                                        child: Container(
                                          height: _size.width > 650
                                              ? _size.height / 35
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  32.4,
                                          width: _size.width > 650
                                              ? _size.width / 25
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                          margin: EdgeInsets.only(
                                              left: _size.width > 650
                                                  ? _size.width / 30
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      53.57),
                                          child: Image.asset(
                                              'images/viewIcon.png',
                                              fit: _size.width > 650
                                                  ? BoxFit.fill
                                                  : BoxFit.none),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                          //UPLOADED DOCUMENTS LIST //
                          Column(
                            children: [
                              //UPLOAD DOCUMENT BOX //
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, 'dealsUploadWithCategory');
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          40.5,
                                      left: _size.width > 650
                                          ? _size.width / 15
                                          : _size.width / 15),
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height:
                                      MediaQuery.of(context).size.height / 5.47,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: homeBoxShadow, width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: uploadDocumentsBorder
                                                .withOpacity(1),
                                            blurRadius: 20,
                                            offset: Offset(0, 3))
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                62.3),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: CircleAvatar(
                                                radius: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    25,
                                                backgroundColor:
                                                    uploadDocumentCircle,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        50),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    23.14,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    10.7,
                                                child: Image.asset(
                                                    'images/uploadIcon.png'),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                90),
                                        child: Text("Upload Documents",
                                            style: TextStyle(
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.bold,
                                                color: uploadDocumentsTitle,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    54)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              //UPLOAD DOCUMENT BOX END //

                              //NOTES BOX START //
                              Container(
                                width: _size.width / 1.15,
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        26.13,
                                    left: _size.width > 650
                                        ? _size.width / 15
                                        : _size.width / 15,
                                    bottom: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: homeBoxShadow, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: uploadDocumentsBorder
                                              .withOpacity(1),
                                          blurRadius: 20,
                                          offset: Offset(0, 3))
                                    ]),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: _size.height / 45),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: _size.width / 17.04),
                                            child: Text("View Notes",
                                                style: TextStyle(
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.bold,
                                                    color: homeAmountColor,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            54)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: _size.width / 19.2),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: keyboardDownIcon,
                                              size: _size.height / 50,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    //NOTES MESSAGE BOX INSIDE A NOTES BOX START//
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: _size.width / 30),
                                      height: 200,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: fetchedNotes.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: _size.width / 1.33,
                                                  margin: EdgeInsets.only(
                                                      top: _size.height / 90,
                                                      bottom:
                                                          _size.height / 54),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: homeBoxShadow,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(20),
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                      color: messageBox,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                uploadDocumentsBorder
                                                                    .withOpacity(
                                                                        1),
                                                            blurRadius: 20,
                                                            offset:
                                                                Offset(0, 3))
                                                      ]),
                                                  child: Container(
                                                      width: _size.width / 1.44,
                                                      margin: EdgeInsets.only(
                                                          top:
                                                              _size.height / 90,
                                                          bottom:
                                                              _size.height / 54,
                                                          left: _size.width /
                                                              31.25),
                                                      child: Text(
                                                        fetchedNotes[index]
                                                                .notes ??
                                                            '',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Quicksand",
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: messageText,
                                                            fontSize:
                                                                _size.height /
                                                                    90),
                                                      )),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 10,
                                                  ),
                                                  child: Text(
                                                    "${fetchedNotes[index].created?.month}-${fetchedNotes[index].created?.day}-${fetchedNotes[index].created?.year}",
                                                    style: TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        color: messageDate,
                                                        fontSize: _size.height /
                                                            115.7),
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                    )
                                    //NOTES MESSAGE BOX INSIDE A NOTES BOX END//
                                  ],
                                ),
                              ),
                              //NOTES BOX END //
                              //QUERY BOX START//
                              Container(
                                width: _size.width / 1.15,
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        26.13,
                                    left: _size.width > 650
                                        ? _size.width / 15
                                        : _size.width / 15,
                                    bottom: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: homeBoxShadow, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: uploadDocumentsBorder
                                              .withOpacity(1),
                                          blurRadius: 20,
                                          offset: Offset(0, 3))
                                    ]),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: _size.height / 45),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: _size.width / 17.04),
                                            child: Text("Queries",
                                                style: TextStyle(
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.bold,
                                                    color: homeAmountColor,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            54)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: _size.width / 19.2),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: keyboardDownIcon,
                                              size: _size.height / 50,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: _size.width / 30),
                                      height: 200,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: queryNotes.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: _size.width / 1.33,
                                                  margin: EdgeInsets.only(
                                                      top: _size.height / 90,
                                                      bottom:
                                                          _size.height / 54),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: homeBoxShadow,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(20),
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                      color: messageBox,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                uploadDocumentsBorder
                                                                    .withOpacity(
                                                                        1),
                                                            blurRadius: 20,
                                                            offset:
                                                                Offset(0, 3))
                                                      ]),
                                                  child: Container(
                                                      width: _size.width / 1.44,
                                                      margin: EdgeInsets.only(
                                                          top:
                                                              _size.height / 90,
                                                          bottom:
                                                              _size.height / 54,
                                                          left: _size.width /
                                                              31.25),
                                                      child: Text(
                                                        queryNotes[index]
                                                                .notes ??
                                                            '',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Quicksand",
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: messageText,
                                                            fontSize:
                                                                _size.height /
                                                                    90),
                                                      )),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 10,
                                                  ),
                                                  child: Text(
                                                    "${queryNotes[index].createdAt?.substring(0, 11)}",
                                                    style: TextStyle(
                                                        fontFamily: "Quicksand",
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        color: messageDate,
                                                        fontSize: _size.height /
                                                            115.7),
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                    )
                                  ],
                                ),
                              ),
                              //QUERY BOX END//

                              //SEND TO MARKET PLACE BUTTON //
                              Provider.of<Data>(context, listen: false)
                                          .dealStatus ==
                                      "new_lead"
                                  ? Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.15,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              20.25,
                                      margin: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              13,
                                          bottom: 100),
                                      child: Roundedbutton(
                                        onPressed: () {
                                          sendToMarketPlace();
                                        },
                                        color: fabColor,
                                        text: "Send to Marketplace",
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                54,
                                      ),
                                    )
                                  : Provider.of<Data>(context, listen: false)
                                              .dealStatus ==
                                          "docs_in"
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.15,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20.25,
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              bottom: 100),
                                          child: Roundedbutton(
                                            onPressed: () {
                                              sendToMarketPlace();
                                            },
                                            color: fabColor,
                                            text: "Send to Marketplace",
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                54,
                                          ),
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.15,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20.25,
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              bottom: 100),
                                        )
                              //SEND TO MARKET PLACE BUTTON//
                              //SEND TO MARKET PLACE BUTTON //
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Notes {
  final String? notes;
  final DateTime? created;
  Notes({this.notes, this.created});
}

class UploadedDocuments {
  final String? title;
  final DateTime? created;
  final String? filePath;
  UploadedDocuments({this.title, this.created, this.filePath});
}

class Query {
  final String? notes;
  final String? createdAt;
  Query({this.createdAt, this.notes});
}
