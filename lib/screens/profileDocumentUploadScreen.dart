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

class ProfileUploadDocumentsWithCategory extends StatefulWidget {
  @override
  _ProfileUploadDocumentsWithCategoryState createState() =>
      _ProfileUploadDocumentsWithCategoryState();
}

class _ProfileUploadDocumentsWithCategoryState
    extends State<ProfileUploadDocumentsWithCategory> {
  File? file;
  String? actualFile;

  String folderName = "";

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
  String? fileName;
  FToast? fToast;

  bool uploading = false;

  Dio dio = new Dio();

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

    fToast?.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 2),
    );
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = File(result.files.single.path ?? '');
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
        file = File(result.files.single.path ?? '');
        fileName = result.files.single.path?.split('/').last;
        actualFile = result.files.single.path;
      });

      print(file);
    } else {
      // User canceled the picker
    }
  }

  //FUNCTION TO UPLOAD FILES//
  uploadFiles() async {
    FormData formData = new FormData.fromMap({
      "method": "upload_profile_documents",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
      "type": Provider.of<Data>(context, listen: false).uploadProfileType,
      "title": Provider.of<Data>(context, listen: false).profileTitle,
      "File": await MultipartFile.fromFile(actualFile!, filename: fileName)
    });
    Response response = await dio.post(baseUrl, data: formData);
    var realData = jsonDecode(response.data);
    var realStatus = realData["response_code"];
    if (realStatus == 100) {
      _showToast("Document Uploaded");
      setState(() {
        Provider.of<Data>(context, listen: false).profileType = "Select type";
        // Provider.of<Data>(context,listen: false).profileScreen=true;
        // Provider.of<Data>(context,listen: false).homeScreen=false;
        // Provider.of<Data>(context,listen: false).notificationScreen=false;
        Provider.of<Data>(context, listen: false).pageNumber = 3;
      });
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      setState(() {
        uploading = !uploading;
      });
      _showToast("Uploading document failed");
    }
  }
  //FUNCTION TO UPLOAD FILES//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    fToast = FToast();
    fToast?.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
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
                    setState(() {
                      Provider.of<Data>(context, listen: false).profileScreen =
                          true;
                      Provider.of<Data>(context, listen: false).homeScreen =
                          false;
                      Provider.of<Data>(context, listen: false)
                          .notificationScreen = false;
                    });
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
                            borderRadius: BorderRadius.all(Radius.circular(16)),
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
                                      radius:
                                          MediaQuery.of(context).size.height /
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              23.14,
                                      width: MediaQuery.of(context).size.width /
                                          10.7,
                                      child:
                                          Image.asset('images/uploadIcon.png'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 90),
                              child: Text("Upload Documents",
                                  style: TextStyle(
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.bold,
                                      color: uploadDocumentsTitle,
                                      fontSize:
                                          MediaQuery.of(context).size.height /
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
                                    child: Text("Upload Images",
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
                    )
                  : Container(),
              //SECOND BUTTON END//

              Opacity(
                opacity: fileName != null ? 1.0 : 0.6,
                child: Container(
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width / 70,
                      top: MediaQuery.of(context).size.height / 38.57),
                  width: MediaQuery.of(context).size.width / 1.15,
                  height: MediaQuery.of(context).size.height / 20.25,
                  child: RoundedButtonUpload(
                    onPressed: () {
                      if (fileName != null) {
                        setState(() {
                          uploading = !uploading;
                        });
                        uploadFiles();
//                        Navigator.pushReplacementNamed(context,'upload');
                      } else {
                        print("select properly");
                      }
                    },
                    color: fabColor,
                    textLoader: uploading
                        ? Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: fabColor,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          )
                        : Text("Upload",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
