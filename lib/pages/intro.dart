// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'home.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key key}) : super(key: key);
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<Slide> slides = [];
  TextStyle kStyleTitle = TextStyle(
    // color: Color(0xff3da4ab),
    color: Colors.black54,
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'RobotoMono',
  );

  TextStyle kStyleDescription = TextStyle(
    color: Color(0xfffe9c8f),
    fontSize: 20.0,
    fontStyle: FontStyle.italic,
    fontFamily: 'Raleway',
  );

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "FACE AUTHENTICATION",
        maxLineTitle: 2,
        styleTitle: kStyleTitle,
        description:
            "Simple and secure. Take a selfie, and mark your attendance!",
        styleDescription: kStyleDescription,
        pathImage: "assets/faceRecog.jpg",
        backgroundColor: Colors.white,
      ),
    );
    slides.add(
      new Slide(
        title: "ONE TIME REGISTRATION",
        maxLineTitle: 2,
        styleTitle: kStyleTitle,
        description:
            "Take the hassle out of attendance! Register once, and you're good to go!",
        styleDescription: kStyleDescription,
        pathImage: "assets/hassle.png",
        backgroundColor: Colors.white,
      ),
    );
    slides.add(
      new Slide(
        title: "GEOFENCING",
        styleTitle: kStyleTitle,
        description:
            "Mark your attendance by simply walking in or out your building!",
        styleDescription: kStyleDescription,
        pathImage: "assets/location.png",
        backgroundColor: Colors.white,
      ),
    );
  }

  void onDonePress() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xffffcc5c),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xffffcc5c),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffffcc5c),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      /// skip button
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: Color(0x33ffcc5c),
      highlightColorSkipBtn: Color(0xffffcc5c),

      /// next button
      renderNextBtn: this.renderNextBtn(),

      /// Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      colorDoneBtn: Color(0x33ffcc5c),
      highlightColorDoneBtn: Color(0xffffcc5c),

      slides: this.slides,
      scrollPhysics: BouncingScrollPhysics(),
      hideStatusBar: true,
    );
  }
}
