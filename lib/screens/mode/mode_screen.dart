import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_contron/models/datamode.dart';
import 'package:flutter_contron/models/datasocketio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({Key? key}) : super(key: key);

  @override
  _ModeScreenState createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  DataModes? _dataModes;
  List<Message> _dataModesList = [];
  Socket? socket;
  String? iduser;
  Timer? _timer;
  String? _Textmode = 'default';
  int checkedIndex = 0;
  String? user_modes;
  DataSocket? _datasocket;
  String? _message;
  bool status = false;
// /#RT=user_id,modes_id$
  getMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    iduser = prefs.getString('userId');
    // user_modes = prefs.getString('user_modes');
    print('iduser = ${iduser}');
    var res = await http.get(Uri.parse('https://sttslife-api.sttslife.co/config/' + iduser.toString()));

    try {
      if (res.statusCode == 200)
        setState(() {
          _dataModes = dataModesFromJson(res.body);
          // checkedIndex = int.parse(user_modes.toString());
        });
      _dataModesList = _dataModes?.message as List<Message>;
      // print(json.encode(_dataModes));
      print(_dataModesList);
      getUser(iduser);
    } catch (e) {
      print(e);
    }
  }

  getUser(id) async {
    var res = await http.get(Uri.parse('https://sttslife-api.sttslife.co/users/' + id.toString()));
    final indexuser_modes = res.body.indexOf('user_modes');
    final index_user_modes = res.body.indexOf(':', indexuser_modes + 5) + 1;
    final indexEnduser_modes = res.body.indexOf(',', index_user_modes);
    final user_modes = res.body.substring(index_user_modes, indexEnduser_modes);

    print(user_modes);
    // _dataModesList.map((data)=>{
    //   print(data)
    // });
    for (var i = 0; i < _dataModesList.length; i++) {
      print(_dataModesList[i].configId);
      if (int.parse(user_modes) == _dataModesList[i].configId) {
        setState(() {
          checkedIndex = i;
        });
        break;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMode();
    // _timer = new Timer(const Duration(milliseconds: 400), () {
    //   initializeSocket();
    // });
    if (iduser != null) {
      initializeSocket();
    } else {
      _timer = new Timer(const Duration(milliseconds: 400), () {
        initializeSocket();
      });
    }
  }

  @override
  void dispose() {
    socket!.disconnect(); // --> disconnects the Socket.IO client once the screen is disposed
    super.dispose();
    _timer?.cancel();
  }

  sendMessage(String message) {
    socket!.emit("newChatMessage", {'body': '${message}', 'senderId': socket!.id});
  }

  void initializeSocket() {
    socket =
        io('http://dns.sttslife.co:4000/', OptionBuilder().setTransports(['websocket']).disableAutoConnect().setQuery({"roomId": iduser}).build());
    socket!.connect(); //connect the Socket.IO Client to the Serverƒ
    //SOCKET EVENTS
    // --> listening for connection
    socket!.on('connect', (data) {
      print(socket!.connected);
    });
    //listen for incoming messages from the Server.
    // socket!.on('newChatMessage', (data) {
    //   // print(data); //
    //   setState(() {
    //     _message = data;
    //     _datasocket = DataSocket.fromJson(jsonDecode(data));
    //   });
    //   // print(_datasocket);
    //   // print(_setledgreen);
    // });
    socket!.on('message', (data) {
      print(data); //
    });

    socket!.on('newChatMessage', (data) {
      if ((data.toString()).indexOf('user_id') != -1) {
        setState(() {
          _message = data;
          _datasocket = DataSocket.fromJson(jsonDecode(data));
        });
      } else if ((data.toString()).indexOf('senderId') != -1) {
        final str = data.toString();
        final commands = str.substring(str.indexOf(':') + 2, str.indexOf(','));
        final atcommands = commands.substring(0, commands.indexOf('='));
        final config_id = commands.substring(commands.indexOf('=') + 1, commands.indexOf('|'));
        final values = commands.substring(commands.indexOf('|') + 1, commands.length);
        // if (atcommands.indexOf('AT+TOGGLE') != -1) {
        //   setState(() {
        //     status = (int.parse(values) == 0 ? false : true);
        //   });
        // }
        if (atcommands.indexOf('AT+MODE') != -1) {
          // เปลี่ยนโหมด
          print('เปลี่ยนโหมด ${values} config_id ${config_id}');
          setState(() {
            checkedIndex = int.parse(values);
          });
          sendUserMode(config_id);
        }
        print('atcommands = ${atcommands} & values = ${values}');
      }

      // print(_datasocket);
      // print(_setledgreen);
    });

    //listens when the client is disconnected from the Server
    socket!.on('disconnect', (data) {
      print('disconnect');
    });
  }

  sendUserMode(idMode) async {
    final body = {'user_modes': idMode.toString()};
    var res = await http.put(
        Uri.parse(
          'https://sttslife-api.sttslife.co/users/modes/${iduser}',
        ),
        body: body);
    if (res.statusCode == 200) {
      print('success ');
    } else {
      print('error');
    }
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
    return WillPopScope(
      // onWillPop: () async {
      //   final difference = DateTime.now().difference(timeBackPressed);
      //   final isExitWaring = difference >= Duration(seconds: 2);
      //   if (isExitWaring) {
      //     final message = 'Press back again to exit';
      //     Fluttertoast.showToast(msg: message, fontSize: 18);
      //     return false;
      //   } else {
      //     Fluttertoast.cancel();
      //     return true;
      //   }
      // },
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Mode ควบคุมการทำงาน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[400]),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ระดับความชอบอากาศร้อน'),
                RatingBar.builder(
                  itemSize: 24,
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ระดับความชอบอากาศหนาว'),
                RatingBar.builder(
                  itemSize: 24,
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 150,
                  child: GridView.builder(
                      itemCount: _dataModesList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2.4), crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        bool checked = index == checkedIndex;
                        return InkWell(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            print('ตั้งค่าโหมดเป็น: #RT=${_dataModesList[index].configId}\$');
                            // sendMessage(
                            //     '#RT=${_dataModesList[index].configId}\$');
                            sendMessage('AT+MODE=${_dataModesList[index].configId}|${index}');
                            sendUserMode(_dataModesList[index].configId);
                            //////put api
                            ///
                            setState(() {
                              _Textmode = _dataModesList[index].configName.toString();
                              checkedIndex = index;
                              // prefs.setString(
                              //     'user_modes', index.toString());
                            });
                            print(checkedIndex);
                          },
                          child: Card(
                            elevation: 4,
                            // color: Colors.green[50],
                            color: checked ? Colors.green[400] : Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Mode',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${_dataModesList[index].configName}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                // /#RT=user_id,modes_id$
                                Icon(Icons.settings)
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
