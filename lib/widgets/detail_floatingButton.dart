import 'package:flutter/material.dart';
import 'package:iso/constants/colors.dart';

class FloatingButtonContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(margin:EdgeInsets.only(bottom:MediaQuery.of(context).size.height/57.9,right: MediaQuery.of(context).size.width/34),
        child: CircleAvatar(backgroundColor: detailFab,radius: MediaQuery.of(context).size.height/30,
          child: Stack(
            children: <Widget>[
              Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right:3.0),
                    child: Container(
                        height:MediaQuery.of(context).size.height/45 ,
                        width: MediaQuery.of(context).size.width>650?MediaQuery.of(context).size.width/25:MediaQuery.of(context).size.width/22,
                        child: Image.asset("images/chatIcon.png",fit: MediaQuery.of(context).size.width>65?BoxFit.fill:BoxFit.none,)),
                  )
//                  Icon(Icons.shopping_cart,color: Colors.white,size: MediaQuery.of(context).size.height/30,),
              ),
            ],
          ),));
  }
}