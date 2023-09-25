import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/services/apiEndPoints.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iso/widgets/rounded_button_upload.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart';

class DealsUploadDocumentsWithCategory extends StatefulWidget {
//  final Function onPressedClose;
//  DealsUploadDocumentsWithCategory({this.onPressedClose});
  @override
  _DealsUploadDocumentsWithCategoryState createState() =>
      _DealsUploadDocumentsWithCategoryState();
}

class _DealsUploadDocumentsWithCategoryState
    extends State<DealsUploadDocumentsWithCategory> {
  File? file;
  String? actualFile;
  String category = "Select the category";
  String month = "Select the month";
  String folderName = "";
  int? monthToPass;
  bool categorySelected = false;
  bool monthSelected = false;
  bool loading = false;
  List<String> allCategories = [
    "3 Months Bank Statement",
    "3 Months Credit Card Statement",
    "Driving License",
    "FCS Document",
    "Signed Contract",
    "Lease",
    "Other",
    "Signed Application",
    "Voided Check",
    "Unsigned Contract",
    "People Information",
  ];
  List<String> allFolderNames = [
    "3month_bank_statement",
    "3month_cc_statement",
    "driving_license",
    "fcs",
    "esign_document",
    "lease",
    "other",
    "signed_application",
    "voided_check",
    "unsigned_document",
    "pipl"
  ];
  List<String> allMonths = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<int> monthNumber = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  String? fileName;
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

  Dio dio = new Dio();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        fileName = result.files.single.path?.split('/').last;
        actualFile = result.files.single.path;
      });

      print(file);
    } else {
      // User canceled the picker
    }
  }

  void _openFileExplorerImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        fileName = result.files.single.path?.split('/').last;
        actualFile = result.files.single.path;
      });

      print(file);
    } else {
      // User canceled the picker
    }
  }

  //FUNCTION TO UPLOAD DOCUMENT//
  uploadFiles() async {
    FormData formData = new FormData.fromMap({
      "method": "upload_documents",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "deal_id": Provider.of<Data>(context, listen: false).dealId,
      "folder_name[0]": folderName,
      "title[0]": category,
      "token": Provider.of<Data>(context, listen: false).token,
      "File[0]": await MultipartFile.fromFile(
        actualFile ?? '',
        filename: fileName,
      ),
      "month[0]": monthToPass
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
      print("Document uploaded");
      Fluttertoast.showToast(
          msg: "Document Uploaded",
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          gravity: ToastGravity.CENTER);

      // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Document Uploaded")));
      Navigator.pushReplacementNamed(context, 'detailed');
    } else {
      setState(() {
        loading = !loading;
      });
      Fluttertoast.showToast(
          msg: "Uploading document failed",
          textColor: Colors.white,
          backgroundColor: Colors.grey,
          gravity: ToastGravity.CENTER);
      // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Uploading document failed")));
    }
  }
  //FUNCTION TO UPLOAD DOCUMENT//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            setState(() {
              categorySelected = false;
              monthSelected = false;
            });
          },
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'detailed');
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

                    GestureDetector(
                      onTap: () {
                        _openFileExplorer();
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
                                        top:
                                            MediaQuery.of(context).size.height /
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
                                        top:
                                            MediaQuery.of(context).size.height /
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //SECOND BUTTON START//
                    Platform.isIOS
                        ? GestureDetector(
                            onTap: () {
                              _openFileExplorerImage();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 45),
                              width: MediaQuery.of(context).size.width / 1.15,
                              height: MediaQuery.of(context).size.height / 5.47,
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
                                    width: MediaQuery.of(context).size.width /
                                        1.24,
                                    height: MediaQuery.of(context).size.height /
                                        6.23,
                                    margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                90),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: uploadDocumentsDashedBorder,
                                            width: 1,
                                            style: BorderStyle.solid),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: uploadDocumentsDashedShadow
                                                  .withOpacity(1),
                                              blurRadius: 10,
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
                                                      top:
                                                          MediaQuery.of(context)
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
                                          child: Text("Upload Images",
                                              style: TextStyle(
                                                  fontFamily: "Quicksand",
                                                  fontWeight: FontWeight.bold,
                                                  color: uploadDocumentsTitle,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          54)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    //SECOND BUTTON END//
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          categorySelected = !categorySelected;
                        });
                      },
                      child: Container(
                        width: _size.width / 1.15,
                        height: MediaQuery.of(context).size.height / 20.25,
                        margin: EdgeInsets.only(top: _size.height / 45),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(color: textFieldBorder, width: 1),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w400,
                                      color: hintTextColor),
                                ),
                              ),
                              Container(
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    category == "3 Months Bank Statement" ||
                            category == "3 Months Credit Card Statement"
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                monthSelected = !monthSelected;
                              });
                            },
                            child: Container(
                              width: _size.width / 1.15,
                              height:
                                  MediaQuery.of(context).size.height / 20.25,
                              margin: EdgeInsets.only(top: _size.height / 45),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                    color: textFieldBorder, width: 1),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(
                                        month,
                                        style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w400,
                                            color: hintTextColor),
                                      ),
                                    ),
                                    Container(
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    Opacity(
                      opacity: category != "Select the category" &&
                              category != "3 Months Bank Statement" &&
                              category != "3 Months Credit Card Statement" &&
                              fileName != null
                          ? 1.0
                          : category == "3 Months Bank Statement" &&
                                  fileName != null &&
                                  month != "Select the month"
                              ? 1.0
                              : category == "3 Months Credit Card Statement" &&
                                      fileName != null &&
                                      month != "Select the month"
                                  ? 1.0
                                  : 0.6,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 70,
                            top: MediaQuery.of(context).size.height / 38.57),
                        width: MediaQuery.of(context).size.width / 1.15,
                        height: MediaQuery.of(context).size.height / 20.25,
                        child: RoundedButtonUpload(
                            onPressed: () {
                              if (category == "3 Months Bank Statement" &&
                                  fileName != null &&
                                  month != "Select the month") {
                                setState(() {
                                  loading = !loading;
                                });
                                uploadFiles();
                              }

                              if (category ==
                                      "3 Months Credit Card Statement" &&
                                  fileName != null &&
                                  month != "Select the month") {
                                setState(() {
                                  loading = !loading;
                                });
                                uploadFiles();
                              }

                              if (category != "Select the category" &&
                                  category != "3 Months Bank Statement" &&
                                  category !=
                                      "3 Months Credit Card Statement" &&
                                  fileName != null) {
                                setState(() {
                                  loading = !loading;
                                });
                                uploadFiles();
                              }
                            },
                            color: fabColor,
                            textLoader: loading
                                ? Container(
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: fabColor,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white),
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
              categorySelected
                  ? Center(
                      child: Container(
                      height: _size.height / 3,
                      width: _size.width / 1.15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        border: Border.all(color: textFieldBorder, width: 1),
                      ),
                      child: ListView.builder(
                          padding: EdgeInsets.only(top: 0),
                          itemCount: allCategories.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  category = allCategories[index];
                                  categorySelected = !categorySelected;
                                  folderName = allFolderNames[index];
                                });
                              },
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(left: 20),
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        allCategories[index],
                                        style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w400,
                                            color: hintTextColor),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      height: 1,
                                      width: double.infinity,
                                      color: textFieldBorder,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ))
                  : monthSelected
                      ? Center(
                          child: Container(
                          height: _size.height / 3,
                          width: _size.width / 1.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border:
                                Border.all(color: textFieldBorder, width: 1),
                          ),
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 0),
                              itemCount: allMonths.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      month = allMonths[index];
                                      monthSelected = !monthSelected;
                                      monthToPass = monthNumber[index];
                                    });
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.only(left: 20),
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            allMonths[index],
                                            style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.w400,
                                                color: hintTextColor),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          height: 1,
                                          width: double.infinity,
                                          color: textFieldBorder,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ))
                      : Container()
            ],
          ),
        ),
      ),
    );
  }
}
