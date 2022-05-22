// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SettingPage extends StatefulWidget {
  final BluetoothCharacteristic? characteristicTX;
  final BluetoothCharacteristic? characteristicRX;
  final double? vAlarm;
  final double? frpAlarm;
  final double? vfrpAlarm;
  final int? modeType;
  const SettingPage(
      {Key? key,
      required this.characteristicTX,
      required this.characteristicRX,
      required this.vAlarm,
      required this.frpAlarm,
      required this.vfrpAlarm,
      required this.modeType})
      : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  double _currentSliderValue1 = 0;
  double _currentSliderValue2 = 0;
  double _currentSliderValue3 = 0.00;
  int _modeType = 0;
  @override
  void initState() {
    _currentSliderValue1 = widget.vAlarm!;
    _currentSliderValue2 = widget.frpAlarm!;
    _currentSliderValue3 = widget.vfrpAlarm!;
    _modeType = widget.modeType!;
  }

  Widget build(BuildContext context) {
    var sizewidth = MediaQuery.of(context).size.width;
    var sizeheight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/setting-page/bg.jpg'),
              fit: BoxFit.cover),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .25,
                  // color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '    SETTING',
                    style: TextStyle(
                      fontFamily: 'Facon',
                      fontSize: (sizewidth / 2) * 0.07,
                      color: Color.fromRGBO(252, 248, 237, 1),
                      shadows: const [
                        Shadow(
                            // bottomLeft
                            offset: Offset(1.2, 1.2),
                            color: Colors.red),
                        Shadow(
                            // bottomRight
                            offset: Offset(1.2, 1.2),
                            color: Colors.red),
                        Shadow(
                            // topRight
                            offset: Offset(1.2, 1.2),
                            color: Colors.red),
                        Shadow(
                            // topLeft
                            offset: Offset(1.8, 1.8),
                            color: Colors.red),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .15,
                  // color: Colors.green,
                  child: Row(
                    children: [
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .25,
                        // color: Colors.white,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'VOLT ALARM',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .50,
                        // color: Colors.yellow,
                        child: Slider(
                          value: _currentSliderValue1,
                          min: 0,
                          max: 15,
                          divisions: 15,
                          label: _currentSliderValue1.round().toString(),
                          onChanged: (double newValue) {
                            setState(() {
                              _currentSliderValue1 = newValue;
                            });
                          },
                          onChangeEnd: (value) {
                            print('###### value1 ${value.toStringAsFixed(2)}');
                            if (widget.characteristicRX != null) {
                              sendData('AT+BAT=${value.toStringAsFixed(2)}');
                            }
                          },
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .15,
                        // color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          '${_currentSliderValue1.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .10,
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  V',
                          style: TextStyle(
                            // fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.06,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .15,
                  // color: Colors.red,
                  child: Row(
                    children: [
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .25,
                        // color: Colors.white,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'FRP ALARM',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .50,
                        // color: Colors.yellow,
                        child: Slider(
                          value: _currentSliderValue2,
                          min: 0,
                          max: 240,
                          divisions: 240,
                          label: _currentSliderValue2.round().toString(),
                          onChanged: (double newValue) {
                            setState(() {
                              _currentSliderValue2 = newValue;
                            });
                          },
                          onChangeEnd: (value) {
                            print(
                                '###### value2 ${value.round().toStringAsFixed(0)}');
                            if (widget.characteristicRX != null) {
                              sendData('AT+FRP=${value.toStringAsFixed(0)}');
                            }
                          },
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .15,
                        // color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          '${_currentSliderValue2.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .10,
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  Mpa',
                          style: TextStyle(
                            // fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.06,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .15,
                  // color: Colors.green,
                  child: Row(
                    children: [
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .25,
                        // color: Colors.white,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'VFRP ALARM',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .50,
                        // color: Colors.yellow,
                        child: Slider(
                          value: _currentSliderValue3,
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          label: _currentSliderValue3.toStringAsFixed(2),
                          onChanged: (double newValue) {
                            setState(() {
                              _currentSliderValue3 = newValue;
                            });
                          },
                          onChangeEnd: (value) {
                            print('###### value3 ${value.toStringAsFixed(2)}');
                            if (widget.characteristicRX != null) {
                              sendData('AT+VFRP=${value.toStringAsFixed(2)}');
                            }
                          },
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .15,
                        // color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          '${_currentSliderValue3.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .10,
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  V',
                          style: TextStyle(
                            // fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.06,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .10,
                  // color: Colors.red,
                  child: Row(
                    children: [
                      Container(
                        height: sizeheight * .10,
                        width: (sizewidth * .80) * .25,
                        // color: Colors.white,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'MODE TYPE',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .50,
                        // color: Colors.yellow,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              minWidth: 100,
                              // color: Colors.red,
                              onPressed: () {
                                print('#################AT+MTYPE=0');
                                if (widget.characteristicRX != null) {
                                  sendData('AT+MTYPE=0');
                                }
                                setState(() {
                                  _modeType = 0;
                                });
                              },
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontFamily: 'Facon',
                                  fontSize: (sizewidth / 2) * 0.05,
                                  color: Color.fromRGBO(252, 248, 237, 1),
                                  shadows: const [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(1.8, 1.8),
                                        color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                            FlatButton(
                              minWidth: 100,
                              // color: Colors.green,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  sendData('AT+MTYPE=1');
                                  print('AT+MTYPE=1');
                                }
                                setState(() {
                                  _modeType = 1;
                                });
                              },
                              child: Text(
                                '2',
                                style: TextStyle(
                                  fontFamily: 'Facon',
                                  fontSize: (sizewidth / 2) * 0.05,
                                  color: Color.fromRGBO(252, 248, 237, 1),
                                  shadows: const [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.red),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(1.8, 1.8),
                                        color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .15,
                        // color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          '${(_modeType + 1).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.red),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: sizeheight * .15,
                        width: (sizewidth * .80) * .10,
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sizewidth * .80,
                  height: sizeheight * .10,
                  // color: Colors.green,
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'EXIT',
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: (sizewidth / 2) * 0.06,
                        color: Color.fromRGBO(252, 248, 237, 1),
                        shadows: const [
                          Shadow(
                              // bottomLeft
                              offset: Offset(1.2, 1.2),
                              color: Colors.red),
                          Shadow(
                              // bottomRight
                              offset: Offset(1.2, 1.2),
                              color: Colors.red),
                          Shadow(
                              // topRight
                              offset: Offset(1.2, 1.2),
                              color: Colors.red),
                          Shadow(
                              // topLeft
                              offset: Offset(1.8, 1.8),
                              color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void sendData(String value) async {
    if (widget.characteristicRX!.uuid != null) {
      widget.characteristicRX!.write(utf8.encode(value));
    }
  }
}
