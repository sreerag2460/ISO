import 'package:flutter/material.dart';
import 'package:iso/screens/dealsDocumentUploadScreen.dart';
import 'package:iso/screens/detailed_page.dart';
import 'package:iso/screens/home_screen.dart';
import 'package:iso/screens/login_page.dart';
import 'package:iso/screens/openIsoForm.dart';
import 'package:iso/screens/openUrlPage.dart';
import 'package:iso/screens/openw9Form.dart';
import 'package:iso/screens/profileDocumentUploadScreen.dart';
import 'package:iso/screens/splash_screen.dart';
import 'package:iso/screens/upload_document_screen.dart';
import 'package:iso/screens/upload_document_screen_category.dart';
import 'package:iso/screens/viewDocuments.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
//    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case 'login':
        return MaterialPageRoute(builder: (context) => LoginPage());

      case 'home':
        return MaterialPageRoute(builder: (context) => HomeScreen());

      case 'upload':
        return MaterialPageRoute(builder: (context) => DocumentUploadScreen());

      case 'detailed':
        return MaterialPageRoute(builder: (context) => DetailedPage());

      case 'uploadWithCategory':
        return MaterialPageRoute(
            builder: (context) => UploadDocumentsWithCategory());

      case 'dealsUploadWithCategory':
        return MaterialPageRoute(
            builder: (context) => DealsUploadDocumentsWithCategory());

      case 'profileUploadWithCategory':
        return MaterialPageRoute(
            builder: (context) => ProfileUploadDocumentsWithCategory());

      case 'offerPage':
        return MaterialPageRoute(builder: (context) => OfferPage());

      case 'isoForm':
        return MaterialPageRoute(builder: (context) => IsoFormPage());

      case 'w9Form':
        return MaterialPageRoute(builder: (context) => W9FormPage());

      case 'view':
        return MaterialPageRoute(builder: (context) => ViewDoc());
    }
    return null;
  }
}
