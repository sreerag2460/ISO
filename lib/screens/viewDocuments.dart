import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewDoc extends StatefulWidget {
  @override
  _ViewDocState createState() => _ViewDocState();
}

class _ViewDocState extends State<ViewDoc> {
  WebViewController? controller;
  @override
  void initState() {
    super.initState();
    const controllerParams = PlatformWebViewControllerCreationParams();
    controller = WebViewController.fromPlatformCreationParams(controllerParams)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            print(error.toString());
          },
          onPageFinished: (finish) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(
          Uri.parse(Provider.of<Data>(context, listen: false).isoFormUrl));
    final params =
        PlatformWebViewWidgetCreationParams(controller: controller!.platform);
    if (Platform.isAndroid)
      WebViewWidget.fromPlatformCreationParams(params: params);
    print(Provider.of<Data>(context, listen: false).viewDocUrl);
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: new AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                margin: EdgeInsets.only(bottom: 0, left: 10),
                child: Icon(Icons.arrow_back,
                    color: Colors.black, size: _size.width / 10)),
          ),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Container(
                  width: double.infinity,
                  child: WebViewWidget(controller: controller!)
                  // WebView(
                  //   // initialUrl: "https://www.google.com",
                  //   initialUrl:
                  //       Provider.of<Data>(context, listen: false).viewDocUrl,
                  //   javascriptMode: JavascriptMode.unrestricted,
                  //   onPageFinished: (finish) {
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //   },
                  // ),
                  ),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: fabColor,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Stack(),
          ],
        ));
  }
}
