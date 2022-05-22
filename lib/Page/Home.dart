// ignore_for_file: file_names, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ricther69/Page/DATALOG.dart';
import 'package:ricther69/Page/Setting.dart';
import 'package:ricther69/bluetooth/settingble.dart';
import 'package:ricther69/bluetooth/valueProvider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:permission_handler/permission_handler.dart';

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
    // bool serviceEnabled;
    // LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   return Future.error(
    //       'GPS ถูกปิดกรุณาเปิดเพื่อร้องขอความเร็วรถยนต์จาก GPS.');
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     return Future.error(
    //         'GPS ถูกปิดกรุณาเปิดเพื่อร้องขอความเร็วรถยนต์จาก GPS.');
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error(
    //       'GPS ถูกปิดกรุณาเปิดเพื่อร้องขอความเร็วรถยนต์จาก GPS.');
    // }

    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        findSpeed();
      } else if (status.isDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('แจ้งเตือน'),
            content:
                Text('GPS ถูกปิดกรุณาเปิดเพื่ออ่านค่าความเร็วรถยนต์'),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  // exit(0);
                },
                child: Text('ตั้งค่า'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // await Geolocator.openLocationSettings();
                  // exit(0);
                },
                child: Text('ไว้คราวหลัง'),
                // child: Text('ข้ามไปก่อน'), 
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('GPS ถูกปิดกรุณาเปิดเพื่อร้องขอความเร็วรถยนต์จาก GPS.'),
          content: Text('GPS ถูกปิดกรุณาเปิดเพื่อร้องขอความเร็วรถยนต์จาก GPS.'),
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

  // Future<Null> checkPermission() async {
  //   BluetoothCharacteristic? characteristic;

  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // bool locationService;
  //   // LocationPermission locationPermission;
  //   // locationService = await Geolocator.isLocationServiceEnabled();
  //   // if (locationService) {
  //   //   print('Service Location Open');

  //   //   locationPermission = await Geolocator.checkPermission();
  //   //   if (locationPermission == LocationPermission.denied) {
  //   //     locationPermission = await Geolocator.requestPermission();
  //   //     if (locationPermission == LocationPermission.deniedForever) {
  //   //       // showDialog(
  //   //       //   context: context,
  //   //       //   builder: (context) => AlertDialog(
  //   //       //     title: Text('Localtion Service ปิดอยู่ ?'),
  //   //       //     content: Text('กรุณาเปิด Localtion Service'),
  //   //       //     actions: [
  //   //       //       TextButton(
  //   //       //         onPressed: () async {
  //   //       //           await Geolocator.openLocationSettings();
  //   //       //           exit(0);
  //   //       //         },
  //   //       //         child: Text('OK'),
  //   //       //       ),
  //   //       //     ],
  //   //       //   ),
  //   //       // );
  //   //     } else {
  //   //       // Find LatLang
  //   //       findSpeed();
  //   //     }
  //   //   } else {
  //   //     if (locationPermission == LocationPermission.deniedForever) {
  //   //       // showDialog(
  //   //       //   context: context,
  //   //       //   builder: (context) => AlertDialog(
  //   //       //     title: Text('Localtion Service ปิดอยู่ ?'),
  //   //       //     content: Text('กรุณาเปิด Localtion Service'),
  //   //       //     actions: [
  //   //       //       TextButton(
  //   //       //         onPressed: () async {
  //   //       //           await Geolocator.openLocationSettings();
  //   //       //           exit(0);
  //   //       //         },
  //   //       //         child: Text('OK'),
  //   //       //       ),
  //   //       //     ],
  //   //       //   ),
  //   //       // );
  //   //     } else {
  //   //       // Find LatLng
  //   //       findSpeed();
  //   //     }
  //   //   }
  //   // } else {
  //   //   // print('Service Location Close');
  //   //   // showDialog(
  //   //   //   context: context,
  //   //   //   builder: (context) => AlertDialog(
  //   //   //     title: Text('Localtion Service ปิดอยู่ ?'),
  //   //   //     content: Text('กรุณาเปิด Localtion Service'),
  //   //   //     actions: [
  //   //   //       TextButton(
  //   //   //         onPressed: () async {
  //   //   //           await Geolocator.openLocationSettings();
  //   //   //           exit(0);
  //   //   //         },
  //   //   //         child: Text('OK'),
  //   //   //       ),
  //   //   //     ],
  //   //   //   ),
  //   //   // );
  //   // }
  // }

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
                RangePointer(
                  value: context.watch<valueProvider>().battery,
                  width: 0.5,
                  cornerStyle: CornerStyle.bothFlat,
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
                    width: (size / 2) * 0.35,
                    height: sizeh * 0.2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Color.fromRGBO(55, 54, 51, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 45,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
                GaugeAnnotation(
                  widget: Container(
                    width: (size / 2) * 0.35,
                    height: (sizeh / 2) * .45,
                    alignment: Alignment.center,
                    child: Text(
                      context.watch<valueProvider>().battery.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 45,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
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
                    width: (size / 2) * 0.35,
                    height: sizeh * 0.2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Color.fromRGBO(55, 54, 51, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 45,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
                GaugeAnnotation(
                  widget: Container(
                    width: (size / 2) * 0.35,
                    height: (sizeh / 2) * .5,
                    alignment: Alignment.center,
                    child: Text(
                      context.watch<valueProvider>().frp.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 50,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
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
                    width: (size / 2) * 0.35,
                    height: sizeh * 0.2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Color.fromRGBO(55, 54, 51, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      speed.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 45,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  angle: 60,
                  positionFactor: 0.7,
                ),
                GaugeAnnotation(
                  widget: Container(
                    width: (size / 2) * 0.35,
                    height: (sizeh / 2) * .5,
                    alignment: Alignment.center,
                    child: Text(
                      context.watch<valueProvider>().vfrp.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Facon',
                        fontSize: 50,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
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
              // decoration: BoxDecoration(color: Colors.yellow),
              width: size / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      // Bluetooth
                      // decoration: BoxDecoration(color: Colors.blue),
                      width: (size / 2),
                      height: sizeh * 0.1,
                      // color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Image.asset('assets/images/ble-logo.png'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingBle()));
                        },
                      )),
                  Container(
                    // Data
                    // decoration: BoxDecoration(color: Colors.green),
                    width: (size / 2),
                    height: sizeh * 0.75,
                    child: Column(
                      children: [
                        Container(
                          // Data
                          // decoration: BoxDecoration(color: Colors.white),
                          width: (size / 2),
                          height: (sizeh * 0.75) * 0.2,
                          child: Row(
                            children: [
                              Container(
                                width: (size / 2) * 0.4,
                                height: (sizeh * 0.75) * 0.2,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'BATTERY',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.05,
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
                                width: (size / 2) * 0.35,
                                height: (sizeh * 0.75) * 0.15,
                                // color: Colors.black12,
                                alignment: Alignment.center,
                                // padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Color.fromRGBO(55, 54, 51, 1),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  context
                                      .watch<valueProvider>()
                                      .battery
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
                                    color: Color.fromRGBO(252, 248, 237, 1),
                                  ),
                                ),
                              ),
                              Container(
                                width: (size / 2) * 0.25,
                                height: (sizeh * 0.75) * 0.2,
                                alignment: Alignment.centerLeft,
                                // color: Colors.purple,
                                child: Text(
                                  '  V',
                                  style: TextStyle(
                                    // fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.05,
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
                          // Data
                          // decoration: BoxDecoration(color: Colors.yellow),
                          width: (size / 2),
                          height: (sizeh * 0.75) * 0.2,
                          child: Row(
                            children: [
                              Container(
                                width: (size / 2) * 0.4,
                                height: (sizeh * 0.75) * 0.2,
                                // color: Colors.orange,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'PEAK FRP',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.05,
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
                                width: (size / 2) * 0.35,
                                height: (sizeh * 0.75) * 0.15,
                                // color: Colors.black12,
                                alignment: Alignment.center,
                                // padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Color.fromRGBO(55, 54, 51, 1),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  context
                                      .watch<valueProvider>()
                                      .pfrp
                                      .toStringAsFixed(0),
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
                                    color: Color.fromRGBO(252, 248, 237, 1),
                                  ),
                                ),
                              ),
                              Container(
                                width: (size / 2) * 0.2,
                                height: (sizeh * 0.75) * 0.25,
                                alignment: Alignment.centerLeft,
                                // color: Colors.purple,
                                child: Text(
                                  '  Mpa',
                                  style: TextStyle(
                                    // fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
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
                          // Data
                          // decoration: BoxDecoration(color: Colors.white38),
                          width: (size / 2),
                          height: (sizeh * 0.75) * 0.2,
                          child: Row(
                            children: [
                              Container(
                                width: (size / 2) * 0.4,
                                height: (sizeh * 0.75) * 0.2,
                                // color: Colors.orange,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'PEAK VFRP',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.05,
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
                                width: (size / 2) * 0.35,
                                height: (sizeh * 0.75) * 0.15,
                                // color: Colors.black12,
                                alignment: Alignment.center,
                                // padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Color.fromRGBO(55, 54, 51, 1),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  context
                                      .watch<valueProvider>()
                                      .pvfrp
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
                                    color: Color.fromRGBO(252, 248, 237, 1),
                                  ),
                                ),
                              ),
                              Container(
                                width: (size / 2) * 0.25,
                                height: (sizeh * 0.75) * 0.2,
                                alignment: Alignment.centerLeft,
                                // color: Colors.purple,
                                child: Text(
                                  '  V',
                                  style: TextStyle(
                                    // fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
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
                          // Data
                          // decoration: BoxDecoration(color: Colors.white54),
                          // color: Colors.yellow,
                          width: (size / 2),
                          height: (sizeh * 0.75) * 0.2,
                          child: Row(
                            children: [
                              Container(
                                width: (size / 2) * 0.4,
                                height: (sizeh * 0.75) * 0.2,
                                // color: Colors.orange,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'TOP SPEED',
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.05,
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
                                width: (size / 2) * 0.35,
                                height: (sizeh * 0.75) * 0.15,
                                // color: Colors.black12,
                                alignment: Alignment.center,
                                // padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Color.fromRGBO(55, 54, 51, 1),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  context
                                      .watch<valueProvider>()
                                      .tspeed
                                      .toStringAsFixed(0),
                                  style: TextStyle(
                                    fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
                                    color: Color.fromRGBO(252, 248, 237, 1),
                                  ),
                                ),
                              ),
                              Container(
                                width: (size / 2) * 0.25,
                                height: (sizeh * 0.75) * 0.2,
                                alignment: Alignment.centerLeft,
                                // color: Colors.purple,
                                child: Text(
                                  '  Km/hr',
                                  style: TextStyle(
                                    // fontFamily: 'Facon',
                                    fontSize: (size / 2) * 0.055,
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
                          // Data
                          // decoration: BoxDecoration(color: Colors.red),
                          // color: Colors.red,
                          width: (size / 2),
                          height: (sizeh * 0.75) * 0.2,
                          alignment: Alignment.center,
                          child: FlatButton(
                            onPressed: () {
                              if (widget.characteristicTX != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DATALOG(
                                              characteristicTX:
                                                  widget.characteristicTX,
                                              characteristicRX:
                                                  widget.characteristicRX,
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
                                fontSize: sizeh * 0.05,
                                color: Color.fromRGBO(252, 248, 237, 1),
                                shadows: const [
                                  Shadow(
                                    // bottomLeft
                                    offset: Offset(1.2, 1.2),
                                    color: Color.fromRGBO(0, 0, 255, 1),
                                  ),
                                  Shadow(
                                    // bottomRight
                                    offset: Offset(1.2, 1.2),
                                    color: Color.fromRGBO(0, 0, 255, 1),
                                  ),
                                  Shadow(
                                    // topRight
                                    offset: Offset(1.2, 1.2),
                                    color: Color.fromRGBO(0, 0, 255, 1),
                                  ),
                                  Shadow(
                                    // topLeft
                                    offset: Offset(1.8, 1.8),
                                    color: Color.fromRGBO(0, 0, 255, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // Mode
                    // decoration: BoxDecoration(color: Colors.red),
                    width: (size / 2),
                    height: sizeh * 0.15,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Row(
                                children: [
                                  Text(
                                    'MODE',
                                    style: TextStyle(
                                      fontFamily: 'Facon',
                                      fontSize: sizeh * 0.045,
                                      color: Color.fromRGBO(252, 248, 237, 1),
                                      shadows: const [
                                        Shadow(
                                          // bottomLeft
                                          offset: Offset(1.2, 1.2),
                                          color: Color.fromRGBO(0, 0, 255, 1),
                                        ),
                                        Shadow(
                                          // bottomRight
                                          offset: Offset(1.2, 1.2),
                                          color: Color.fromRGBO(0, 0, 255, 1),
                                        ),
                                        Shadow(
                                          // topRight
                                          offset: Offset(1.2, 1.2),
                                          color: Color.fromRGBO(0, 0, 255, 1),
                                        ),
                                        Shadow(
                                          // topLeft
                                          offset: Offset(1.8, 1.8),
                                          color: Color.fromRGBO(0, 0, 255, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset('assets/images/batt.png'),
                                    iconSize: size * 0.05,
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
                                    iconSize: size * 0.05,
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
                                    iconSize: size * 0.05,
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
                                    iconSize: size * 0.05,
                                    onPressed: () {
                                      if (widget.characteristicTX != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SettingPage(
                                                      characteristicTX: widget
                                                          .characteristicTX,
                                                      characteristicRX: widget
                                                          .characteristicRX,
                                                      frpAlarm: double.parse(
                                                          context
                                                              .watch<
                                                                  valueProvider>()
                                                              .frpalarm
                                                              .toStringAsFixed(
                                                                  2)),
                                                      modeType: int.parse(context
                                                          .watch<
                                                              valueProvider>()
                                                          .modetype
                                                          .toStringAsFixed(0)),
                                                      vAlarm: double.parse(context
                                                          .watch<
                                                              valueProvider>()
                                                          .voltalarm
                                                          .toStringAsFixed(2)),
                                                      vfrpAlarm: double.parse(
                                                          context
                                                              .watch<
                                                                  valueProvider>()
                                                              .vfrpalarm
                                                              .toStringAsFixed(
                                                                  2)),
                                                    )));
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SettingPage(
                                              characteristicTX: null,
                                              characteristicRX: null,
                                              frpAlarm: 0,
                                              modeType: 0,
                                              vAlarm: 0,
                                              vfrpAlarm: 0,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
