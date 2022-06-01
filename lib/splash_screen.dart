import 'package:flutter/material.dart';
import 'package:flutter_contron/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // navigatetohome();
  }

  // navigatetohome() async {
  //   await Future.delayed(Duration(milliseconds: 5000), () {});
  //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
  // }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: sized_box_for_whitespace
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: h / 2,
              width: w / 2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/CH07B0.png"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
