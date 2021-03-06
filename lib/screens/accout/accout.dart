// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contron/models/datauserlogin.dart';

import 'package:flutter_contron/screens/accout/edit_password.dart';
import 'package:flutter_contron/screens/accout/editaccout.dart';
import 'package:flutter_contron/services/api.dart';
import 'package:flutter_contron/utilities/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class AccoutScreen extends StatefulWidget {
  const AccoutScreen({Key? key}) : super(key: key);

  @override
  _AccoutScreenState createState() => _AccoutScreenState();
}

class _AccoutScreenState extends State<AccoutScreen> {
  final Color primaryColors = Color.fromARGB(255, 0, 140, 255);
  DataUser? _dataUser;
  String? username;
  String? password;
  String? iduser;
  File? _image;
  String? name_flie;
  bool? aa = false;
  final picker = ImagePicker();
  final f = new DateFormat('yyyy-MM-dd');
  Future getImage(ImageSource imageSource) async {
    final pickedfile = await picker.getImage(source: imageSource);
    setState(() {
      if (pickedfile != null) {
        _image = File(pickedfile.path);
        print(_image);
        upload(_image!.path);
      } else {
        print('no image selected');
      }
    });
  }

  upload(filePath) async {
    try {
      final postUri =
          Uri.parse('https://sttslife-api.sttslife.co/upload-image/${iduser}');
      setState(() {
        name_flie = filePath.split('/').last;
      });
      print(name_flie);
      http.MultipartRequest request = http.MultipartRequest('POST', postUri);
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: name_flie,
        contentType: MediaType(
          'image',
          'png',
        ),
      ); //returns a Future<MultipartFile>
      request.files.add(multipartFile);
      http.StreamedResponse response = await request.send();
      //update_namefile();
      var responsed = await http.Response.fromStream(response);
      final responseData = json.decode(responsed.body);
      if (response.statusCode == 200) {
        print("SUCCESS");
        print(responseData);
      } else {
        print("ERROR");
      }
    } catch (err) {
      // tar_widget().showInSnackBar('??????????????????????????????????????????????????????????????????????????????', Colors.white,
      //     _scaffoldKey, Colors.red, 4);
    }
  }

  getUserprofile() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('user_username');
    password = sharedPreferences.getString('user_password');
    iduser = sharedPreferences.getString('userId');
    print('username : ${username}');
    print('password :${password}');
    print('iduser :${iduser}');
    var userData = {
      'user_username': username,
      'user_password': password,
    };
    try {
      var res = await CallAPI().getProfile(userData);
      print(res);
      setState(() {
        _dataUser = res;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getImage();
    getUserprofile();
  }

  getDataTime() {
    final dateNow = DateTime.now();
    final dateEnd = DateTime.parse('${_dataUser?.message?[0].userEndwaranty}');
    final differenceDay = dateEnd.difference(dateNow).inDays;
    return differenceDay;
  }

  DateTime timeBackPressed = DateTime.now();
  @override
  Widget build(BuildContext context) {
    Future<bool?>? showWarning(context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure ?'),
              content: Text('do you want to exit an App'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Yes'),
                ),
              ],
            ));
    if (_dataUser != null) {
      getDataTime();

      return WillPopScope(
        onWillPop: () async {
          final shouldPop = await showWarning(context);
          return shouldPop ?? false;
        },
        child: Container(
          child: Stack(
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),

                        Center(
                          child: Text(
                            '????????????????????????????????????',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColors),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Center(
                          child: Stack(
                            children: [
                              // Container(
                              //   width: 130,
                              //   height: 130,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //         width: 4,
                              //         color: Theme.of(context)
                              //             .scaffoldBackgroundColor),
                              //     boxShadow: [
                              //       BoxShadow(
                              //           spreadRadius: 2,
                              //           blurRadius: 10,
                              //           color: Colors.black.withOpacity(0.1),
                              //           offset: Offset(0, 10))
                              //     ],
                              //     shape: BoxShape.circle,
                              //     image: DecorationImage(
                              //       image: imgVariable,
                              //       fit: BoxFit.cover,
                              //     ),
                              //   ),
                              // ),
                              Container(
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //       width: 4,
                                //       color: Theme.of(context)
                                //           .scaffoldBackgroundColor),
                                //   boxShadow: [
                                //     BoxShadow(
                                //         spreadRadius: 2,
                                //         blurRadius: 10,
                                //         color: Colors.black.withOpacity(0.1),
                                //         offset: Offset(0, 10))
                                //   ],
                                //   shape: BoxShape.circle,

                                // ),

                                child: Image.network(
                                  'https://sttslife-api.sttslife.co/images/${iduser}.png',
                                  height: 130,
                                  width: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.cover,
                                      height: 130,
                                      width: 130,
                                    );
                                  },
                                ),
                              ),

                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 4,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                      color: primaryColors,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        print('editimage??');

                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) =>
                                              CupertinoActionSheet(
                                            title:
                                                Text("???????????????????????????????????????????????????????????????"),
                                            actions: [
                                              CupertinoActionSheetAction(
                                                onPressed: () {
                                                  getImage(ImageSource.camera);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Camera",
                                                ),
                                              ),
                                              CupertinoActionSheetAction(
                                                onPressed: () {
                                                  getImage(ImageSource.gallery);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Gallery",
                                                ),
                                              )
                                            ],
                                            cancelButton: CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Cancel',
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FlatButton(
                                onPressed: () {
                                  print('?????????????????????????????????????????????');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditPassword()));
                                },
                                child: Text(
                                  '?????????????????????????????????????????????',
                                  style: TextStyle(color: primaryColors),
                                )),
                          ],
                        ),
                        Divider(
                          thickness: 0.4,
                          color: primaryColors,
                        ),
                        const SizedBox(height: 10),
                        // Container(
                        //   color: Colors.red,
                        //   child: ListTile(
                        //     title: Text(
                        //       '???????????????????????????????????????',
                        //       style: kProfileStyle,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: primaryColors,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              )),
                          child: Text(
                            '???????????????????????????????????????',
                            style: kProfileStyle.copyWith(color: Colors.white),
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].userUsername.toString()}',
                          ),
                        ),
                        ListTile(
                          title: Text('???????????????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].userTel}',
                          ),
                        ),
                        ListTile(
                          title: Text('?????????????????????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].userDetail}',
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].userLocaltion}',
                          ),
                        ),
                        // Divider(
                        //   thickness: 1,
                        //   color: Colors.green[400],
                        // ),

                        // ListTile(
                        //   title: Text(
                        //     '???????????????????????????????????????',
                        //     style: kProfileStyle,
                        //   ),
                        // ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: primaryColors,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              )),
                          child: Text(
                            '???????????????????????????????????????',
                            style: kProfileStyle.copyWith(color: Colors.white),
                          ),
                        ),
                        ListTile(
                          title: Text('???????????????????????????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].userPurchaseorder}',
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].airBrand}',
                          ),
                        ),
                        ListTile(
                          title: Text('????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].airBtu}',
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].airSpecies}',
                          ),
                        ),
                        ListTile(
                          title: Text('????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].airType}',
                          ),
                        ),
                        ListTile(
                          title: Text('???????????????????????????????????????'),
                          subtitle: Text(
                            '${_dataUser?.message?[0].airLifetime}',
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????????????????????????????'),
                          subtitle: Text(
                            f.format(
                              DateTime.parse(
                                  '${_dataUser?.message?[0].userStartwaranty}'),
                            ),
                          ),
                        ),
                        // ListTile(
                        //   title: Text('????????????????????????????????????'),
                        //   subtitle: Text(
                        //     f.format(
                        //       DateTime.parse(
                        //           '${_dataUser?.message?[0].userEndwaranty}'),
                        //     ),
                        //   ),
                        //   trailing: Text(
                        //     '???????????????????????????????????? : ${differenceDay} ?????????',
                        //     style: TextStyle(color: Colors.black54),
                        //   ),
                        // ),
                        ListTile(
                          title: Text('????????????????????????????????????'),
                          subtitle: Text(
                            f.format(
                              DateTime.parse(
                                  '${_dataUser?.message?[0].userEndwaranty}'),
                            ),
                          ),
                          trailing: Text(
                            getDataTime() <= 0
                                ? '???????????????????????????????????????'
                                : '???????????????????????????????????? : ${getDataTime()} ?????????',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        ListTile(
                          title: Text('??????????????????????????????????????????????????????????????????????????????'),
                          subtitle: Text(
                            '${f.format(
                              DateTime.parse(
                                  '${_dataUser?.message?[0].userCleanair}'),
                            )}',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10.0),
                              child: RaisedButton(
                                onPressed: _launchUrl,
                                color: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  "???????????????????????????",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.4,
                          color: primaryColors,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlineButton(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () async {
                                // SharedPreferences sharedPreferences =
                                //     await SharedPreferences.getInstance();
                                // sharedPreferences.remove('test_image');
                                // sharedPreferences.remove('userId');
                                // sharedPreferences.remove('user_modes');
                                // sharedPreferences.setInt('appStep', 2);
                                // Navigator.pushReplacementNamed(context, '/login');
                                // // loginUser(userData);
                                // print('logout');
                                showAlertDialog(context);
                              },
                              child: Text("Logout",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.black)),
                            ),
                            RaisedButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditAccoutScreen()));
                                // Navigator.pushNamed(
                                //     context, '/editaccout');
                                // // loginUser(userData);
                                print('editprofile');
                              },
                              color: primaryColors,
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: SpinKitFadingCircle(
          duration: Duration(milliseconds: 2000),
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }
  }

  void _launchUrl() async {
    // if (!await launchUrl(_url)) throw 'Could not launch $_url';

    const url = 'https://line.me/R/ti/p/@469iogbl';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("??????????????????"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("??????????????????"),
      onPressed: () async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.remove('test_image');
        sharedPreferences.remove('userId');
        sharedPreferences.remove('user_modes');
        sharedPreferences.setInt('appStep', 2);
        Navigator.pushReplacementNamed(context, '/login');
        // loginUser(userData);
        print('logout');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("?????????????????????????????? ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
