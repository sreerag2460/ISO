import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/constants/button_decoration.dart';
import 'package:iso/widgets/rounded_button_upload.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import '../services/apiEndPoints.dart';

class DocumentUploadScreen extends StatefulWidget {
  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool keyBoardVisible = false;
  bool uploading = false;
  String number = "";
  String companyName = "";
  List<FormData> toUpload = [];
  var unusedFocusNode = FocusNode();
  Dio dio = new Dio();
  FToast? fToast;
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

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    return fToast?.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 2),
    );
  }

  //FUNCTION TO UPLOAD FILES//
  uploadFiles() async {
    for (int index = 0;
        index < Provider.of<Data>(context, listen: false).file.length;
        index++) {
      FormData formData = new FormData.fromMap({
        "method": "upload_documents",
        "username": API_USERNAME,
        "password": API_PASSWORD,
        "phone_number": number,
        "company_name": companyName,
        "folder_name[0]":
            Provider.of<Data>(context, listen: false).folderName[index],
        "title[0]": Provider.of<Data>(context, listen: false).title[index],
        "token": Provider.of<Data>(context, listen: false).token,
        "File[0]": await MultipartFile.fromFile(
            Provider.of<Data>(context, listen: false).actualFile[index],
            filename: Provider.of<Data>(context, listen: false).file[index]),
        "month[0]": Provider.of<Data>(context, listen: false)
            .monthToPassNewUpload[index]
      });
      Response response = await dio.post(baseUrl,
          data: formData,
          options: Options(
            followRedirects: false,
            // will not throw errors
            validateStatus: (status) => true,
          ));
      var realData = jsonDecode(response.data);
      var realStatus = realData["response_code"];

      print("Response $realData");
      if (realStatus == 100) {
        setState(() {
          print("Document$index uploaded");
          _showToast("Document ${index + 1} Uploaded");
          // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Document$index uploaded")));
        });
      } else {
        setState(() {
          uploading = !uploading;
        });
        print("Uploading failed");
        _showToast("Uploading document failed");
        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Document$index uploaded failed")));
      }
      if (realStatus == 100 &&
          index == Provider.of<Data>(context, listen: false).file.length - 1) {
        setState(() {
          Provider.of<Data>(context, listen: false).folderName.clear();
          Provider.of<Data>(context, listen: false).title.clear();
          Provider.of<Data>(context, listen: false).actualFile.clear();
          Provider.of<Data>(context, listen: false).file.clear();
          Provider.of<Data>(context, listen: false).profileScreen = false;
          Provider.of<Data>(context, listen: false).homeScreen = true;
          Provider.of<Data>(context, listen: false).notificationScreen = false;
          Provider.of<Data>(context, listen: false).pageNumber = 1;
          Provider.of<Data>(context, listen: false)
              .monthToPassNewUpload
              .clear();
        });
        Navigator.pushReplacementNamed(context, "home");
      }

//
//        MapEntry("File", await MultipartFile.fromFile(Provider.of<Data>(context,listen: false).actualFile[index],filename:Provider.of<Data>(context,listen: false).file[index] ))
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("UPLOAD DOCUMENT SCREEN");
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    fToast = FToast();
    fToast?.init(context);
    print(Provider.of<Data>(context, listen: false).monthToPassNewUpload);
  }

  //FUNCTION TO UPLOAD FILES//
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
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(unusedFocusNode);
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: backgroundGrey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<Data>(context, listen: false)
                            .folderName
                            .clear();
                        Provider.of<Data>(context, listen: false).title.clear();
                        Provider.of<Data>(context, listen: false)
                            .actualFile
                            .clear();
                        Provider.of<Data>(context, listen: false).file.clear();
                        Navigator.pushReplacementNamed(context, 'home');
                      },
                      child: Container(
                        height: 40,
                        width: 50,
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 27.27,
                            top: MediaQuery.of(context).size.height / 25),
                        child: Image.asset('images/close.png'),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      "Upload Documents",
                      style: TextStyle(
                          fontFamily: "Quicksand",
                          fontWeight: FontWeight.bold,
                          color: uploadDocumentsTitle,
                          fontSize: MediaQuery.of(context).size.height / 54),
                    ),
                  ),

                  //UPLOAD DOCUMENTS BOX START//
                  GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      Navigator.pushReplacementNamed(
                          context, 'uploadWithCategory');
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 45),
                      width: MediaQuery.of(context).size.width / 1.15,
                      height: MediaQuery.of(context).size.height / 5.47,
                      decoration: BoxDecoration(
                          border: Border.all(color: homeBoxShadow, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: uploadDocumentsBorder.withOpacity(1),
                                blurRadius: 20,
                                offset: Offset(0, 3))
                          ]),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.24,
                            height: MediaQuery.of(context).size.height / 6.23,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 90),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: uploadDocumentsDashedBorder,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: uploadDocumentsDashedShadow
                                          .withOpacity(1),
                                      blurRadius: 10,
                                      offset: Offset(0, 3))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
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
                                          backgroundColor: uploadDocumentCircle,
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
                                      top: MediaQuery.of(context).size.height /
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
                        ],
                      ),
                    ),
                  ),

                  //UPLOAD DOCUMENTS BOX END//
                  // DOCUMENT LIST BOX START//
                  Container(
                    height: keyBoardVisible
                        ? MediaQuery.of(context).size.height / 9
                        : MediaQuery.of(context).size.height / 2.4,
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 17.5,
                        right: MediaQuery.of(context).size.width / 17.5),
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount: Provider.of<Data>(context, listen: false)
                            .title
                            .length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: MediaQuery.of(context).size.height / 14.72,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 36.8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: documentListBoxBorder, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                color: documentListBox,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          documentListBoxShadow.withOpacity(1),
                                      blurRadius: 20,
                                      offset: Offset(0, 0))
                                ]),
                            child: Row(
                              children: [
                                Container(
                                    height: MediaQuery.of(context).size.height /
                                        14.72,
                                    width: MediaQuery.of(context).size.width /
                                        1.33,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              30.5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              17.85,
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  17.04),
                                          child:
                                              Image.asset('images/jpgIcon.png'),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  31.25),
                                          child: Text(
                                              Provider.of<Data>(context,
                                                      listen: false)
                                                  .title[index],
                                              style: TextStyle(
                                                  fontFamily: "Quicksand",
                                                  fontWeight: FontWeight.w400,
                                                  color: homeAmountColor,
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      color: Colors.white,
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Provider.of<Data>(context, listen: false)
                                          .file
                                          .removeAt(index);
                                      Provider.of<Data>(context, listen: false)
                                          .title
                                          .removeAt(index);
                                      Provider.of<Data>(context, listen: false)
                                          .folderName
                                          .removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        32.4,
                                    width:
                                        MediaQuery.of(context).size.width / 15,
                                    margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                53.57),
                                    child: Image.asset('images/deleteIcon.png'),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  // DOCUMENT LIST BOX END//
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: MediaQuery.of(context).size.height / 20.25,
                            margin: EdgeInsets.only(
                                top: keyBoardVisible
                                    ? MediaQuery.of(context).size.height / 54
                                    : MediaQuery.of(context).size.height /
                                        27.93),
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: textFieldShadow.withOpacity(1),
                                  blurRadius: 10,
                                  offset: Offset(0, 3))
                            ]),
                            child: TextField(
                              style: TextStyle(
                                  color: hintTextColor,
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.w400),
                              decoration: kuserInputButtons.copyWith(
                                  hintText: "Phone Number"),
                              cursorColor: hintTextColor,
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                setState(() {
                                  number = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: MediaQuery.of(context).size.height / 20.25,
                            margin: EdgeInsets.only(
                                top: keyBoardVisible
                                    ? MediaQuery.of(context).size.height / 81
                                    : MediaQuery.of(context).size.height /
                                        38.57),
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: textFieldShadow.withOpacity(1),
                                  blurRadius: 10,
                                  offset: Offset(0, 3))
                            ]),
                            child: TextField(
                              style: TextStyle(
                                  color: hintTextColor,
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.w400),
                              decoration: kuserInputButtons.copyWith(
                                  hintText: "Company Name"),
                              cursorColor: hintTextColor,
                              onChanged: (value) {
                                setState(() {
                                  companyName = value;
                                });
                              },
                            ),
                          ),
                          Opacity(
                            opacity: Provider.of<Data>(context, listen: false)
                                        .title
                                        .isNotEmpty &&
                                    companyName.isNotEmpty &&
                                    number.isNotEmpty
                                ? 1.0
                                : 0.6,
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width / 70,
                                  top: MediaQuery.of(context).size.height /
                                      38.57),
                              width: MediaQuery.of(context).size.width / 1.15,
                              height:
                                  MediaQuery.of(context).size.height / 20.25,
                              child: RoundedButtonUpload(
                                  onPressed: () {
                                    if (number != "" &&
                                        companyName != "" &&
                                        Provider.of<Data>(context,
                                                listen: false)
                                            .file
                                            .isNotEmpty) {
                                      setState(() {
                                        uploading = !uploading;
                                      });
                                      uploadFiles();
//                              print(Provider.of<Data>(context,listen: false).file.length);
                                    }
                                  },
                                  color: fabColor,
                                  textLoader: uploading
                                      ? Container(
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
                                        )
                                      : Text("Upload",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Quicksand",
                                              fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
