import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iso/constants/button_decoration.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'dart:convert';

import 'package:iso/services/apiEndPoints.dart';
import 'package:iso/widgets/rounded_button_profile.dart';
import 'package:iso/widgets/sign_box.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<UploadedDocuments> documentsUploaded = [];
  List pendingDocuments = [];
  bool typeSelected = false;
  List<String> typeOfDocuments = [
    "Driving License",
    "ISO agreement esign",
    "Voided Check",
    "W9"
  ];
  List<String> uploadType = [
    "driving_license",
    "iso_agreement_esign",
    "voided_check",
    "w9"
  ];

  Future<List<UploadedDocuments>> fetchUploadedDocuments() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "method": "get_profile_documents",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
    });
    var jsonData = jsonDecode(data.body);
    var responseCode = jsonData["response_code"];
    var realData = jsonData["response_data"]["data"]["uploaded_documents"];
    var pendingData = jsonData["response_data"]["data"]["pending_documents"];

    print("uploadedstatus$responseCode");
    print("uploadedDocuments$realData");
    print("pendingDocuments$pendingData");

    if (responseCode == 100) {
      setState(() {
        pendingDocuments = pendingData;
      });
      for (var u in realData) {
        UploadedDocuments uploadedDocuments = UploadedDocuments(
            docType: u["doc_type"],
            uploadedAt: DateTime.parse(u["uploaded_at"]),
            filePath: u["file_path"]);
        setState(() {
          documentsUploaded.add(uploadedDocuments);
        });
      }
    }
    return documentsUploaded;
  }

  //FUNCTION TO FETCH URL//
  fetchUrl() async {
    var data = await http.post(Uri.parse(baseUrl), body: {
      "method": "get_profile_documents",
      "username": API_USERNAME,
      "password": API_PASSWORD,
      "token": Provider.of<Data>(context, listen: false).token,
    });
    var jsonData = jsonDecode(data.body);
    var responseCode = jsonData["response_code"];
    var isoUrl =
        jsonData["response_data"]["data"]["forms"]["iso_agreement_form"];
    var w9Form = jsonData["response_data"]["data"]["forms"]["w9_form"];
    print("look for error 4$isoUrl");
    print("look for error 5$w9Form");

    if (responseCode == 100) {
      setState(() {
        Provider.of<Data>(context, listen: false).isoFormUrl = isoUrl;
        Provider.of<Data>(context, listen: false).w9FormUrl = w9Form;
      });
    }
  }

  //FUNCTION TO FETCH URL//
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("init state");
    fetchUploadedDocuments();
    fetchUrl();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            typeSelected = false;
          });
        },
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      Container(
                        height: 500,
                        color: profileScreenBackground,
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2.5,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 20),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height / 5,
                            backgroundColor: profileScreenCircle,
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height / 10,
                                    left:
                                        MediaQuery.of(context).size.width / 15),
                                child: Image.asset('images/menu-icon.png'),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.8,
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 10,
                                  left: MediaQuery.of(context).size.width / 15),
                              child: Provider.of<Data>(context, listen: false)
                                          .userName !=
                                      null
                                  ? Text(
                                      Provider.of<Data>(context, listen: false)
                                          .userName!
                                          .toUpperCase(),
                                      style: TextStyle(
                                          fontFamily: "Quicksand",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              47.6),
                                      textAlign: TextAlign.right,
                                    )
                                  : SizedBox(),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 10,
                                  left: MediaQuery.of(context).size.width / 30),
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.height / 25,
                                backgroundColor: profileIconCircle,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          23.8,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              40.64,
                                      child: Image.asset(
                                        'images/profileIconCircle.png',
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  ],
                                ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 27),
                              child: Row(
                                children: [
                                  GestureDetector(
                                      onTap: Provider.of<Data>(context,
                                                      listen: false)
                                                  .isoFormUrl ==
                                              "signed"
                                          ? () {}
                                          : () {
                                              Navigator.pushNamed(
                                                  context, "isoForm");
                                            },
                                      child: SignBox(
                                          title: "Sign ISO Agreement",
                                          opacity: Provider.of<Data>(context,
                                                          listen: false)
                                                      .isoFormUrl ==
                                                  "signed"
                                              ? 0.5
                                              : 1)),
                                  GestureDetector(
                                      onTap: Provider.of<Data>(context,
                                                      listen: false)
                                                  .w9FormUrl ==
                                              "signed"
                                          ? () {}
                                          : () {
                                              Navigator.pushNamed(
                                                  context, "w9Form");
                                            },
                                      child: SignBox(
                                        title: "Sign W9",
                                        opacity: Provider.of<Data>(context,
                                                        listen: false)
                                                    .w9FormUrl ==
                                                "signed"
                                            ? 0.5
                                            : 1,
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.15,
                              height:
                                  MediaQuery.of(context).size.height / 20.25,
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height /
                                      47.65,
                                  left: MediaQuery.of(context).size.width / 15),
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
                                    fontWeight: FontWeight.w500),
                                decoration: kuserInputButtons.copyWith(
                                    hintText: "Title"),
                                cursorColor: hintTextColor,
                                onChanged: (value) {
                                  setState(() {
                                    Provider.of<Data>(context, listen: false)
                                        .profileTitle = value;
                                  });
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  typeSelected = !typeSelected;
                                });
                              },
                              child: Container(
                                width: _size.width / 1.15,
                                height:
                                    MediaQuery.of(context).size.height / 20.25,
                                margin: EdgeInsets.only(
                                    top: _size.height / 45,
                                    left: _size.width / 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(
                                      color: textFieldBorder, width: 1),
                                ),
                                child: Container(
                                  color: Colors.white,
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          Provider.of<Data>(context,
                                                  listen: false)
                                              .profileType,
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
                            RoundedbuttonProfile(
                              color: Colors.white,
                              text: Provider.of<Data>(context, listen: false)
                                  .profileType,
                              onPressed: () {
                                if (Provider.of<Data>(context, listen: false)
                                        .profileType !=
                                    "Select type") {
                                  Navigator.pushReplacementNamed(
                                      context, 'profileUploadWithCategory');
                                }
                              },
                            ),
                            //STRAIGHT LINE START //
                            Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width / 1.15,
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height /
                                      22.82,
                                  left: MediaQuery.of(context).size.width / 15),
                              color: lineColor,
                            ),
                            //STRAIGHT LINE END //
                            // Container(
                            //   margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/39.5,left: MediaQuery.of(context).size.width/15),
                            //   child: Text("Underwriting Status Checklist",style: TextStyle(fontFamily: "Quicksand",fontWeight: FontWeight.bold,color: profilePageHeading,fontSize: MediaQuery.of(context).size.height/54)),),
                            //
                            // Container(
                            //   margin: EdgeInsets.only(top: 2,left: MediaQuery.of(context).size.width/15),
                            //   child: Text('Please submit missing documents',style: TextStyle(fontFamily: "Quicksand",fontWeight: FontWeight.bold,color: profilePageSubHeading,fontSize: MediaQuery.of(context).size.height/67.5),),
                            // ),

                            // ListView.builder(
                            //     padding: EdgeInsets.zero,
                            //     physics: NeverScrollableScrollPhysics(),
                            //     shrinkWrap: true,
                            //     itemCount: pendingDocuments.length,
                            //     itemBuilder: (BuildContext context, int index){
                            //       return Container(
                            //         width: MediaQuery.of(context).size.width/1.15,
                            //         height:MediaQuery.of(context).size.height/16.2 ,
                            //         margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/36.8,left: MediaQuery.of(context).size.width/15,right: MediaQuery.of(context).size.width/15),
                            //         decoration: BoxDecoration(
                            //             border: Border.all(color: documentListBoxBorder,width: 1),
                            //             borderRadius: BorderRadius.all(Radius.circular(16)),
                            //             color: documentListBox,
                            //             boxShadow: [
                            //               BoxShadow(
                            //                   color:documentListBoxShadow.withOpacity(1),
                            //                   blurRadius: 20,
                            //                   offset: Offset(0,0)
                            //               )
                            //             ]
                            //         ),
                            //         child: Row(
                            //           children: [
                            //             Container(
                            //                 height:MediaQuery.of(context).size.height/14.72 ,
                            //                 width: MediaQuery.of(context).size.width/1.33,
                            //                 child: Row(
                            //                   children: [
                            //                     Container(
                            //                       height:MediaQuery.of(context).size.height/30.5,
                            //                       width: MediaQuery.of(context).size.width/17.85,
                            //                       margin:EdgeInsets.only(left: MediaQuery.of(context).size.width/23.44),
                            //                       child: Image.asset('images/crossIcon.png'),
                            //                     ),
                            //                     Container(
                            //                       margin:EdgeInsets.only(left: MediaQuery.of(context).size.width/31.25),
                            //                       child: Text(pendingDocuments[index]=="driving_license"?"Driving License":
                            //                       pendingDocuments[index]=="iso_agreement_esign"?"ISO agreement esign":
                            //                       pendingDocuments[index]=="tlo"?"TLO":
                            //                       pendingDocuments[index]=="voided_check"?"Voided Check":
                            //                       pendingDocuments[index]=="w9"?"W9":"",style: TextStyle(fontFamily: "Quicksand",fontWeight: FontWeight.w400,color: homeAmountColor,fontSize: MediaQuery.of(context).size.height/67.5)),
                            //                     )
                            //                   ],
                            //                 ),
                            //                 decoration: BoxDecoration(
                            //                   border: Border.all(color: documentListBoxBorder,width: 1),
                            //                   borderRadius: BorderRadius.all(Radius.circular(16)),
                            //                   color: Colors.white,
                            //                 )
                            //
                            //
                            //             ),
                            //             Container(
                            //               height: MediaQuery.of(context).size.height/32.4,
                            //               width: MediaQuery.of(context).size.width/15,
                            //               margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/53.57),
                            //               child: Image.asset('images/uploadSmallIcon.png'),
                            //             )
                            //           ],
                            //         ),
                            //
                            //       );
                            //     }),
                            // Container(
                            //   height: 1,
                            //   width: MediaQuery.of(context).size.width/1.15,
                            //   margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/22.82,left: MediaQuery.of(context).size.width/15),
                            //   color: lineColor,
                            //
                            // ),

                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height / 39.5,
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

                            ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: documentsUploaded.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.15,
                                    height: MediaQuery.of(context).size.height /
                                        16.2,
                                    margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                36.8,
                                        left:
                                            MediaQuery.of(context).size.width /
                                                15,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                15),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: documentListBoxBorder,
                                            width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
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
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              23.44),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              47.64,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              22.06,
                                                      child: Image.asset(
                                                          'images/greenTick.png'),
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
                                                          documentsUploaded[
                                                                          index]
                                                                      .docType ==
                                                                  "w9"
                                                              ? "W9"
                                                              : documentsUploaded[
                                                                              index]
                                                                          .docType ==
                                                                      "voided_check"
                                                                  ? "Voided Check"
                                                                  : documentsUploaded[index]
                                                                              .docType ==
                                                                          "driving_license"
                                                                      ? "Driving License"
                                                                      : documentsUploaded[index].docType ==
                                                                              "iso_agreement_esign"
                                                                          ? "ISO Agreement esign"
                                                                          : "",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Quicksand",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                          "${documentsUploaded[index].uploadedAt?.month}-${documentsUploaded[index].uploadedAt?.day}-${documentsUploaded[index].uploadedAt?.year}",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Quicksand",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
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
                                            Navigator.pushNamed(
                                                context, "view");
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                32.4,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    53.57),
                                            child: Image.asset(
                                                'images/viewIcon.png'),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            typeSelected
                ? Center(
                    child: Container(
                    height: _size.height / 5,
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
                        itemCount: typeOfDocuments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                Provider.of<Data>(context, listen: false)
                                    .profileType = typeOfDocuments[index];
                                Provider.of<Data>(context, listen: false)
                                    .uploadProfileType = uploadType[index];

                                typeSelected = !typeSelected;
                              });
                              print("pressed");
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
                                      typeOfDocuments[index],
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
    );
  }
}

class UploadedDocuments {
  final String? docType;
  final DateTime? uploadedAt;
  final String? filePath;

  UploadedDocuments({this.docType, this.uploadedAt, this.filePath});
}
