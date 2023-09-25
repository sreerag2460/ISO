import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';
import 'package:iso/main.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class IsoFormPage extends StatefulWidget {
  @override
  _IsoFormPageState createState() => _IsoFormPageState();
}

class _IsoFormPageState extends State<IsoFormPage> {
  bool isLoading = true;
  WebViewController? controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    const params = PlatformWebViewControllerCreationParams();
    controller = WebViewController.fromPlatformCreationParams(params)
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
    if (controller?.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller?.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    print("url ${Provider.of<Data>(context, listen: false).offerUrl}");
  }

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
                width: MediaQuery.of(context).size.width,
                child: WebViewWidget(controller: controller!)
//               WebView(
//                 initialUrl:
//                     Provider.of<Data>(context, listen: false).isoFormUrl,
// //            initialUrl: "https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android",
//                 javascriptMode: JavascriptMode.unrestricted,
//                 onPageFinished: (finish) {
//                   setState(() {
//                     isLoading = false;
//                   });
//                 },
//               ),
                ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: fabColor,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Stack(),
        ],
      ),
    );
  }
}
