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

 @override
 void initState() {
   super.initState();

   slides.add(
     new Slide(
       title: "FACE AUTH",
       description: "Allow miles wound place the leave had. To sitting subject no improve studied limited",
       pathImage: "assets/faceRecog.jpg",
       backgroundColor: Color(0xfff5a623),
     ),
   );
   slides.add(
     new Slide(
       title: "PENCIL",
       description: "Ye indulgence unreserved connection alteration appearance",
       pathImage: "assets/location.jpg",
       backgroundColor: Color(0xff203152),
     ),
   );
   slides.add(
     new Slide(
       title: "RULER",
       description:
       "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
       pathImage: "assets/location.jpg",
       backgroundColor: Color(0xff9932CC),
     ),
   );
 }

 void onDonePress() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
 }

 @override
 Widget build(BuildContext context) {
   return new IntroSlider(
     slides: this.slides,
     onDonePress: this.onDonePress,
   );
 }
}