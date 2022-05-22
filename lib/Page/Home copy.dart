// ignore_for_file: file_names, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ricther69/Page/DATALOG.dart';
import 'package:ricther69/Page/Setting.dart';
import 'package:ricther69/bluetooth/settingble.dart';
import 'package:ricther69/bluetooth/valueProvider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  final BluetoothCharacteristic? characteristicRX;
  final BluetoothCharacteristic? characteristicTX;
  const Home(
      {Key? key,
      required this.characteristicRX,
      required this.characteristicTX})
      : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothCharacteristic? characteristic;
  double _volumeValue = 0;
  double speed = 0;
  int frp = 0;
  int vfrp = 0;
  var random = new Random();
  double _min = 0;
  double _max = 100;
  int mode = 0;
  int topspeed = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();

    if (characteristic != null) {
      characteristic = widget.characteristicRX;
    }
    mode = 0;
  }

  // void onVolumeChanged() {
  //   if (mode == 0) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().battery;
  //     });
  //   } else if (mode == 1) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().frp;
  //     });
  //   } else if (mode == 2) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().vfrp;
  //     });
  //   }
  // }

  Future<Null> checkPermission() async {
    bool locationService;
    LocationPermission locationPermission;
    BluetoothCharacteristic? characteristic;
    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');

      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Localtion Service ปิดอยู่ ?'),
              content: Text('กรุณาเปิด Localtion Service'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    exit(0);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Find LatLang
          findSpeed();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Localtion Service ปิดอยู่ ?'),
              content: Text('กรุณาเปิด Localtion Service'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    exit(0);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Find LatLng
          findSpeed();
        }
      }
    } else {
      print('Service Location Close');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Localtion Service ปิดอยู่ ?'),
          content: Text('กรุณาเปิด Localtion Service'),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                exit(0);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Null?> findSpeed() async {
    print('Find findSpeed');
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      print('locationSettings :android ');
      locationSettings = AndroidSettings(
        // accuracy: LocationAccuracy.best,
        // distanceFilter: 2,
        // forceLocationManager: false,
        intervalDuration: const Duration(milliseconds: 500),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      print('locationSettings orter');
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      var speedInMps = position.speed; // this is your speed
      // print('speedInMps = $speedInMps');
      final speed1 = double.parse('$speedInMps') * 3.75;
      context.read<valueProvider>().speed = speed1;
      setState(() {
        speed = speed1;
        // context.read<valueProvider>().speed = speed1;
        if (speed1 >= context.read<valueProvider>().tspeed) {
          context.read<valueProvider>().tspeed = speed1;
        }
      });
      // setState(() {
      // });
    });

    // Geolocator.getPositionStream(locationSettings: locationSettings)
    //     .listen((position) {
    //   var speedInMps = position.speed; // this is your speed
    //   // print('speedInMps = $speedInMps');
    //   context.read<valueProvider>().speed = speedInMps;
    //   setState(() {
    //     speed = double.parse('${speedInMps}');
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var sizeh = MediaQuery.of(context).size.height;

    // Timer.periodic(new Duration(seconds: 8), (timer) {
    //   setState(() {
    //     speed = random.nextInt(150) + 1;
    //     frp = random.nextInt(250) + 1;
    //     vfrp = random.nextInt(250) + 1;
    //   });
    // });

    Widget _buildChild() {
      if (context.watch<valueProvider>().mode == 0) {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 15,
              interval: 1,
              pointers: [
                // NeedlePointer(
                //   needleStartWidth: 1,
                //   needleEndWidth: 5,
                //   // value: context
                //   //     .watch<valueProvider>()
                //   //     .battery,
                //   value: _volumeValue = context.watch<valueProvider>().battery,
                //   enableAnimation: true,
                //   tailStyle:
                //       TailStyle(width: 5, length: 0.15, color: Colors.white),
                //   needleColor: Colors.white,
                // ),
                RangePointer(
                  value: context.watch<valueProvider>().battery,
                  width: 0.5,
                  cornerStyle: CornerStyle.bothFlat,
                  // gradient: SweepGradient(
                  //   colors: const <Color>[Color(0x0ffbbc05), Color(0x0ffbbc05)],
                  //   stops: const <double>[0.0, 0.75],
                  // ),
                  gradient: SweepGradient(
                    colors: const <Color>[Color(0x4fff0000), Color(0x4fff0000)],
                    stops: const <double>[0.0, 0.75],
                  ),
                  sizeUnit: GaugeSizeUnit.factor,
                )
              ],
              axisLabelStyle: GaugeTextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontFamily: 'Facon',
              ),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                // ขอบเกจ
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 80,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
              ],
            ),
          ],
        );
      } else if (context.watch<valueProvider>().mode == 1) {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 270,
              interval: 20,
              pointers: [
                // NeedlePointer(
                //   needleStartWidth: 1,
                //   needleEndWidth: 5,
                //   // value: context
                //   //     .watch<valueProvider>()
                //   //     .battery,
                //   value: _volumeValue = context.watch<valueProvider>().frp,
                //   enableAnimation: true,
                //   tailStyle:
                //       TailStyle(width: 5, length: 0.15, color: Colors.white),
                //   needleColor: Colors.white,
                // ),
                RangePointer(
                    value: context.watch<valueProvider>().frp,
                    width: 0.5,
                    gradient: SweepGradient(
                      colors: const <Color>[
                        Color(0x4fff0000),
                        Color(0x4fff0000)
                      ],
                      stops: const <double>[0.0, 0.75],
                    ),
                    sizeUnit: GaugeSizeUnit.factor)
              ],
              axisLabelStyle: GaugeTextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontFamily: 'Facon',
              ),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 80,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
              ],
            ),
          ],
        );
      } else {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 5,
              interval: 1,
              pointers: [
                // NeedlePointer(
                //   needleStartWidth: 1,
                //   needleEndWidth: 5,
                //   // value: context
                //   //     .watch<valueProvider>()
                //   //     .battery,
                //   value: _volumeValue = context.watch<valueProvider>().vfrp,
                //   enableAnimation: true,
                //   tailStyle:
                //       TailStyle(width: 5, length: 0.15, color: Colors.white),
                //   needleColor: Colors.white,
                // ),
                RangePointer(
                    value: context.watch<valueProvider>().vfrp,
                    width: 0.5,
                    gradient: SweepGradient(
                      colors: const <Color>[
                        Color(0x4fff0000),
                        Color(0x4fff0000)
                      ],
                      stops: const <double>[0.0, 0.75],
                    ),
                    sizeUnit: GaugeSizeUnit.factor)
              ],
              axisLabelStyle: GaugeTextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontFamily: 'Facon',
              ),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 80,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
              ],
            ),
          ],
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg-main.jpg'),
              fit: BoxFit.cover),
        ),
        child: Row(
          children: [
            Container(
              width: size / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/logopng.png'),
                        iconSize: size * 0.08,
                        onPressed: () {},
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: (sizeh * 0.035)),
                          child: SizedBox(
                            height: sizeh * 0.95,
                            child: _buildChild(),
                          ),
                        ),
                      ),
                      Container(
                        height: sizeh,
                        width: size / 2,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            child: IconButton(
                              icon: Image.asset('assets/images/clear.png'),
                              iconSize: sizeh * 0.1,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('AT+CLEAR'));
                                }
                                context.read<valueProvider>().tspeed = 0;
                                print('claer ======= > ');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: size / 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        iconSize: size * 0.08,
                        icon: Image.asset('assets/images/ble-logo.png'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingBle()));
                        },
                      )
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [],
                          ),
                          Container(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'BATTERY',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: 26,
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
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '${context.watch<valueProvider>().battery}',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'v',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PEAK FRP',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: 26,
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
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '${context.watch<valueProvider>().pfrp.toStringAsFixed(0)}',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'mpa',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PEAK VFRP',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: 26,
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
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '${context.watch<valueProvider>().pvfrp}',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'v',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 200,
                            child: Row(
                              children: [
                                Text(
                                  'TOP SPEED',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: 26,
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
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  context
                                      .watch<valueProvider>()
                                      .tspeed
                                      .toStringAsFixed(0),
                                  // '${context.watch<valueProvider>().tspeed.toStringAsFixed(0)}',topspeed
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'km/h',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (widget.characteristicTX != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DATALOG(
                                      characteristicTX: widget.characteristicTX,
                                      characteristicRX: widget.characteristicRX,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DATALOG(
                                      characteristicTX: null,
                                      characteristicRX: null,
                                    )));
                      }
                    },
                    child: Text(
                      'DATALOG',
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 20,
                        color: Color.fromRGBO(0, 0, 255, 1),
                      ),
                    ),
                  ),
                  Text(
                    'Mode = ${mode}',
                    style: TextStyle(color: Colors.white, fontSize: 5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Text(
                              'MODE',
                              style: TextStyle(
                                fontFamily: 'Facon',
                                fontSize: 20,
                                color: Color.fromRGBO(0, 0, 255, 1),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/batt.png'),
                              iconSize: 40,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('AT+MODE=0'));
                                }
                                print('claer ======= > ');
                                context.read<valueProvider>().mode = 0;
                                setState(() {
                                  _min = 0;
                                  _max = 150;
                                  mode = 0;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/frp.png'),
                              iconSize: 55,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('AT+MODE=1'));
                                }

                                context.read<valueProvider>().mode = 1;
                                setState(() {
                                  mode = 1;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/vfrp.png'),
                              iconSize: 50,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('AT+MODE=2'));
                                }
                                context.read<valueProvider>().mode = 2;
                                setState(() {
                                  mode = 2;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset(
                                  'assets/images/setting-logo3.png'),
                              iconSize: 40,
                              onPressed: () {
                                if (widget.characteristicTX != null) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage(
                                                characteristicTX:
                                                    widget.characteristicTX,
                                                characteristicRX:
                                                    widget.characteristicRX,
                                                frpAlarm: double.parse(context
                                                    .watch<valueProvider>()
                                                    .frpalarm
                                                    .toStringAsFixed(2)),
                                                modeType: int.parse(context
                                                    .watch<valueProvider>()
                                                    .modetype
                                                    .toStringAsFixed(0)),
                                                vAlarm: double.parse(context
                                                    .watch<valueProvider>()
                                                    .voltalarm
                                                    .toStringAsFixed(2)),
                                                vfrpAlarm: double.parse(context
                                                    .watch<valueProvider>()
                                                    .vfrpalarm
                                                    .toStringAsFixed(0)),
                                              )));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage(
                                                characteristicTX: null,
                                                characteristicRX: null,
                                                frpAlarm: null,
                                                modeType: null,
                                                vAlarm: null,
                                                vfrpAlarm: null,
                                              )));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: IconButton(
                          icon: Image.asset('assets/images/clear.png'),
                          iconSize: 100,
                          onPressed: () {
                            if (widget.characteristicRX != null) {
                              widget.characteristicRX!
                                  .write(utf8.encode('AT+CLEAR'));
                            }
                            context.read<valueProvider>().tspeed = 0;
                            print('claer ======= > ');
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
