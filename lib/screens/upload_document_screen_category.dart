import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/widgets/rounded_button.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

class UploadDocumentsWithCategory extends StatefulWidget {
  @override
  _UploadDocumentsWithCategoryState createState() =>
      _UploadDocumentsWithCategoryState();
}

class _UploadDocumentsWithCategoryState
    extends State<UploadDocumentsWithCategory> {
  File? file;
  String? actualFile;
  String? category = "Select the category";
  String? folderName = "";
  bool categorySelected = false;
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
  FToast? fToast;
  DateTime? currentBackPressTime;

  bool monthSelected = false;
  int? monthToPass;
  String month = "Select the month";

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
        file = File(result.files.single.path ?? "");
        fileName = result.files.single.path?.split('/').last;
        actualFile = result.files.single.path;
      });

      print(file);
    } else {
      // User canceled the picker
    }
  }

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
    Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
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
                          Navigator.pushReplacementNamed(context, 'upload');
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
                                  category ?? '',
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
                        child: Roundedbutton(
                          onPressed: () {
                            // if(category!="Select the category"&&fileName!=null){
                            //   setState(() {
                            //     Provider.of<Data>(context,listen: false).file.add(fileName);
                            //     Provider.of<Data>(context,listen: false).title.add(category);
                            //     Provider.of<Data>(context,listen: false).folderName.add(folderName);
                            //     Provider.of<Data>(context,listen: false).actualFile.add(actualFile);
                            //   });
                            //   Navigator.pushReplacementNamed(context,'upload');
                            // }
                            // if(category=="Select the category"){
                            //   _showToast("Choose a category");
                            // }
                            // if(fileName==null){
                            //   _showToast("Choose a file to upload");
                            // }
                            if (category == "3 Months Bank Statement" &&
                                fileName != null &&
                                month != "Select the month") {
                              setState(() {
                                Provider.of<Data>(context, listen: false)
                                    .file
                                    .add(fileName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .title
                                    .add(category ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .folderName
                                    .add(folderName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .actualFile
                                    .add(actualFile ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .monthToPassNewUpload
                                    .add(monthToPass ?? 0);
                              });
                              Navigator.pushReplacementNamed(context, 'upload');
                            }

                            if (category == "3 Months Credit Card Statement" &&
                                fileName != null &&
                                month != "Select the month") {
                              setState(() {
                                Provider.of<Data>(context, listen: false)
                                    .file
                                    .add(fileName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .title
                                    .add(category ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .folderName
                                    .add(folderName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .actualFile
                                    .add(actualFile ?? "");
                                Provider.of<Data>(context, listen: false)
                                    .monthToPassNewUpload
                                    .add(monthToPass ?? 0);
                              });
                              Navigator.pushReplacementNamed(context, 'upload');
                            }

                            if (category != "Select the category" &&
                                category != "3 Months Bank Statement" &&
                                category != "3 Months Credit Card Statement" &&
                                fileName != null) {
                              setState(() {
                                Provider.of<Data>(context, listen: false)
                                    .file
                                    .add(fileName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .title
                                    .add(category ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .folderName
                                    .add(folderName ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .actualFile
                                    .add(actualFile ?? '');
                                Provider.of<Data>(context, listen: false)
                                    .monthToPassNewUpload
                                    .add(monthToPass ?? 0);
                              });
                              Navigator.pushReplacementNamed(context, 'upload');
                            }
                          },
                          color: fabColor,
                          text: "Upload",
                        ),
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
                                      height: _size.height / 25,
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
                                          height: _size.height / 25,
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
