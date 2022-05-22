import 'dart:async';
import 'dart:math' as math;
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/src/provider.dart';
import 'package:ricther69/bluetooth/valueProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class DATALOG extends StatefulWidget {
  final BluetoothCharacteristic? characteristicTX;
  final BluetoothCharacteristic? characteristicRX;

  const DATALOG(
      {Key? key,
      required this.characteristicTX,
      required this.characteristicRX})
      : super(key: key);

  @override
  _DATALOGState createState() => _DATALOGState();
}

enum SingingCharacter { lafayette, jefferson }

class _DATALOGState extends State<DATALOG> {
  late int count;
  Timer? timer;
  bool? isrunning;
  bool showFRT = true;
  bool showVFRP = true;
  bool showSPEED = true;
  int valueFRT = 0;
  int valueVFRP = 0;
  late List<ChartSampleData> chartData;
  ChartSeriesController? _chartSeriesController;
  double _minY = 0;
  double _maxY = 270;
  double speed = 0;
  // add
  double batt = 0;
  int frp = 0;
  double vfrp = 0;
  bool isChecked1 = true;
  bool isChecked2 = false;

  late ZoomPanBehavior _zoomPan;
  late TrackballDisplayMode _mode;
  late ChartAlignment _alignment;
  late double duration;
  late bool showAlways;
  StreamSubscription? dataTx;

  late bool canShowMarker;
  late List<String> _modeList;
  late String _selectedMode;
  late List<String> _alignmentList;
  late String _tooltipAlignment;
  late bool _showMarker;
  int data = 0;

  SingingCharacter? _character = SingingCharacter.lafayette;
  int val = -1;
  @override
  void initState() {
    _zoomPan = ZoomPanBehavior(
      // enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
      // enableSelectionZooming: true,
      // zoomMode: ZoomMode.x);
    );
    _modeList =
        <String>['floatAllPoints', 'groupAllPoints', 'nearestPoint'].toList();
    _alignmentList = <String>['center', 'far', 'near'].toList();
    duration = 10;
    showAlways = true;
    canShowMarker = true;
    _selectedMode = 'floatAllPoints';
    _mode = TrackballDisplayMode.floatAllPoints;
    _tooltipAlignment = 'center';
    _showMarker = true;
    _alignment = ChartAlignment.center;

    setState(() {
      isrunning = false;
    });
    count = 0;
    chartData = <ChartSampleData>[];

    super.initState();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  final key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var sizewidth = MediaQuery.of(context).size.width;
    var sizeheight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/datalog-page/bg.jpg'),
              fit: BoxFit.cover),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: sizewidth,
                  height: sizeheight * .12,
                  // color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: sizewidth * .30,
                        height: sizeheight * .12,
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '   FRP DATALOGGER',
                          style: TextStyle(
                            fontFamily: 'Facon',
                            fontSize: (sizewidth / 2) * 0.05,
                            color: const Color.fromRGBO(252, 248, 237, 1),
                            shadows: const [
                              Shadow(
                                  // bottomLeft
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.blue),
                              Shadow(
                                  // bottomRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.blue),
                              Shadow(
                                  // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: Colors.blue),
                              Shadow(
                                  // topLeft
                                  offset: Offset(1.8, 1.8),
                                  color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: sizewidth * .70,
                        height: sizeheight * .12,
                        // color: Colors.black,
                        alignment: Alignment.centerLeft,
                        // child: Row(
                        //   children: [
                        //     Container(
                        //       width: (sizewidth * .70) * .1,
                        //       height: sizeheight * .12,
                        //       // color: Colors.red,
                        //       alignment: Alignment.centerLeft,
                        //     ),
                        //     Container(
                        //       width: (sizewidth * .70) * .28,
                        //       height: sizeheight * .12,
                        //       // color: Colors.red,
                        //       alignment: Alignment.centerLeft,
                        //     ),
                        //     Container(
                        //       // frp
                        //       width: (sizewidth * .70) * .28,
                        //       height: sizeheight * .12,
                        //       // color: Colors.red,
                        //       alignment: Alignment.centerLeft,

                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .3,
                        //             height: sizeheight * .12,
                        //             // color: Colors.white,
                        //             alignment: Alignment.centerLeft,
                        //             child: Text(
                        //               'FRP',
                        //               style: TextStyle(
                        //                 fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.025,
                        //                 color: Color.fromRGBO(252, 248, 237, 1),
                        //                 shadows: const [
                        //                   Shadow(
                        //                       // bottomLeft
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // bottomRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topLeft
                        //                       offset: Offset(1.8, 1.8),
                        //                       color: Colors.red),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .5,
                        //             height: sizeheight * .12,
                        //             // color: Colors.black12,
                        //             alignment: Alignment.center,
                        //             // padding: const EdgeInsets.all(8.0),
                        //             decoration: BoxDecoration(
                        //               color: Colors.black,
                        //               border: Border.all(
                        //                 color: Color.fromRGBO(55, 54, 51, 1),
                        //                 width: 3,
                        //               ),
                        //               borderRadius: const BorderRadius.all(
                        //                 Radius.circular(10),
                        //               ),
                        //             ),
                        //             child: Text(
                        //               '${frp}',
                        //               style: TextStyle(
                        //                 fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.03,
                        //                 color: const Color.fromRGBO(
                        //                     252, 248, 237, 1),
                        //               ),
                        //             ),
                        //           ),
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .2,
                        //             height: sizeheight * .12,
                        //             alignment: Alignment.centerLeft,
                        //             // color: Colors.purple,
                        //             child: Text(
                        //               '',
                        //               // ' Mpa',
                        //               style: TextStyle(
                        //                 fontFamily: 'Facon',
                        //                 // fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.02,
                        //                 color: const Color.fromRGBO(
                        //                     252, 248, 237, 1),
                        //                 shadows: const [
                        //                   Shadow(
                        //                       // bottomLeft
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // bottomRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topLeft
                        //                       offset: Offset(1.8, 1.8),
                        //                       color: Colors.red),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Container(
                        //       // vfrp
                        //       width: (sizewidth * .70) * .28,
                        //       height: sizeheight * .12,
                        //       // color: Colors.blue,
                        //       alignment: Alignment.centerLeft,
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .3,
                        //             height: sizeheight * .12,
                        //             // color: Colors.white,
                        //             alignment: Alignment.centerLeft,
                        //             child: Text(
                        //               ' VFRP',
                        //               style: TextStyle(
                        //                 fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.025,
                        //                 color: Color.fromRGBO(252, 248, 237, 1),
                        //                 shadows: const [
                        //                   Shadow(
                        //                       // bottomLeft
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // bottomRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topLeft
                        //                       offset: Offset(1.8, 1.8),
                        //                       color: Colors.red),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .5,
                        //             height: sizeheight * .12,
                        //             // color: Colors.black12,
                        //             alignment: Alignment.center,
                        //             // padding: const EdgeInsets.all(8.0),
                        //             decoration: BoxDecoration(
                        //               color: Colors.black,
                        //               border: Border.all(
                        //                 color: Color.fromRGBO(55, 54, 51, 1),
                        //                 width: 3,
                        //               ),
                        //               borderRadius: const BorderRadius.all(
                        //                 Radius.circular(10),
                        //               ),
                        //             ),
                        //             child: Text(
                        //               '${vfrp}',
                        //               style: TextStyle(
                        //                 fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.03,
                        //                 color: const Color.fromRGBO(
                        //                     252, 248, 237, 1),
                        //               ),
                        //             ),
                        //           ),
                        //           Container(
                        //             width: ((sizewidth * .70) * .28) * .2,
                        //             height: sizeheight * .12,
                        //             alignment: Alignment.centerLeft,
                        //             // color: Colors.purple,
                        //             child: Text(
                        //               ' ',
                        //               // ' V',
                        //               style: TextStyle(
                        //                 // fontFamily: 'Facon',
                        //                 fontSize: (sizewidth / 2) * 0.03,
                        //                 color: const Color.fromRGBO(
                        //                     252, 248, 237, 1),
                        //                 shadows: const [
                        //                   Shadow(
                        //                       // bottomLeft
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // bottomRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topRight
                        //                       offset: Offset(1.2, 1.2),
                        //                       color: Colors.red),
                        //                   Shadow(
                        //                       // topLeft
                        //                       offset: Offset(1.8, 1.8),
                        //                       color: Colors.red),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: sizewidth * .90,
                  height: sizeheight * .75,
                  // color: Colors.green,
                  alignment: Alignment.center,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: sizewidth * .90,
                    color: Colors.grey,
                    child: _buildLiveLineChart(),
                  ),
                ),
                Container(
                  width: sizewidth*.9,
                  height: sizeheight * .13,
                  // color: Colors.amber,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                                'assets/images/datalog-page/bt-play.png'),
                            iconSize: 50,
                            onPressed: () {
                              setState(() {
                                isrunning = true;
                                print(
                                    'is ======= > Play ===== isrunning ==== ${isrunning}');
                                getdataBle();
                              });
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                                'assets/images/datalog-page/bt-stop.png'),
                            iconSize: 50,
                            onPressed: () {
                              setState(() {
                                _zoomPan.reset();
                                isrunning = false;
                                dataTx?.pause();
                                print(
                                    'is ======= > Stop  isrunning ==== ${isrunning}');
                                // getdataBle();
                              });
                            },
                          ),
                          IconButton(
                            icon: Image.asset('assets/images/clear.png'),
                            iconSize: 50,
                            onPressed: () {
                              chartData.clear();
                              print('is ======= > clear ');
                              _zoomPan.reset();
                              if (isrunning == true) {
                                setState(() {
                                  isrunning = true;
                                });
                              } else {
                                setState(() {
                                  isrunning = false;
                                  dataTx!.cancel();
                                });
                              }

                              setState(() {
                                count = 0;
                              });
                              // getdataBle();
                            },
                          ),
                          //     Row(
                          //       children: [
                          //         Row(
                          //           children: [
                          //             Checkbox(
                          //               checkColor: Colors.white,
                          //               fillColor:
                          //                   MaterialStateProperty.resolveWith(
                          //                       getColor),
                          //               value: isChecked1,
                          //               onChanged: (bool? value) {
                          //                 if (isrunning == false) {
                          //                   setState(() {
                          //                     isChecked1 = value!;
                          //                     isChecked2 = !isChecked1;
                          //                   });
                          //                 }
                          //               },
                          //             ),
                          //             Text(
                          //               'FRP',
                          //               style: TextStyle(
                          //                 fontFamily: 'Facon',
                          //                 fontSize: (sizewidth / 2) * 0.035,
                          //                 color: const Color.fromRGBO(
                          //                     252, 248, 237, 1),
                          //                 shadows: const [
                          //                   Shadow(
                          //                       // bottomLeft
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // bottomRight
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // topRight
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // topLeft
                          //                       offset: Offset(1.8, 1.8),
                          //                       color: Colors.blue),
                          //                 ],
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //         Row(
                          //           children: [
                          //             Checkbox(
                          //               checkColor: Colors.white,
                          //               fillColor:
                          //                   MaterialStateProperty.resolveWith(
                          //                       getColor),
                          //               value: isChecked2,
                          //               onChanged: (bool? value) {
                          //                 if (isrunning == false) {
                          //                   setState(() {
                          //                     isChecked2 = value!;
                          //                     isChecked1 = !isChecked2;
                          //                   });
                          //                 }
                          //               },
                          //             ),
                          //             Text(
                          //               'VFRP',
                          //               style: TextStyle(
                          //                 fontFamily: 'Facon',
                          //                 fontSize: (sizewidth / 2) * 0.035,
                          //                 color: const Color.fromRGBO(
                          //                     252, 248, 237, 1),
                          //                 shadows: const [
                          //                   Shadow(
                          //                       // bottomLeft
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // bottomRight
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // topRight
                          //                       offset: Offset(1.2, 1.2),
                          //                       color: Colors.blue),
                          //                   Shadow(
                          //                       // topLeft
                          //                       offset: Offset(1.8, 1.8),
                          //                       color: Colors.blue),
                          //                 ],
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'EXIT',
                                style: TextStyle(
                                  fontFamily: 'Facon',
                                  fontSize: (sizewidth / 2) * 0.05,
                                  color: const Color.fromRGBO(252, 248, 237, 1),
                                  shadows: const [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.blue),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.blue),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.2, 1.2),
                                        color: Colors.blue),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(1.8, 1.8),
                                        color: Colors.blue),
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
              ],
            ),
          ],
        ),
      ),
    ));
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  double newMap(int x, int inMin, int inMax, int outMin, int outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  void getdataBle() async {
    if (widget.characteristicTX != null) {
      dataTx = widget.characteristicTX!.value.listen((data) {
        final command = _dataParser(data).toString();
        print('data  ========= > ${command}');
        final len = command.indexOf("=");
        // #IN2=5.00$"
        if (command.contains('frp=')) {
          if (isrunning == true) {
            final resultfrp1 =
                command.substring(len + 1, command.length - 1).trim();
            var valueFRTx = double.parse(resultfrp1).toStringAsFixed(0);
            valueFRT = int.parse(valueFRTx);

            var provider = Provider.of<valueProvider>(context, listen: false);
            setState(() {
              speed = provider.speed;
              frp = valueFRT;
              vfrp = provider.vfrp;
            });
            print('######### KUY ===> $resultfrp1');
            print('Data ------------> frp = ${valueFRTx}');

            if (resultfrp1 != null && count != 700) {
              _updateDataSource();
            } else {
              setState(() {
                isrunning = false;
                dataTx!.cancel();
              });
            }
          } else {
            return;
          }
        }
      });
    }
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,

      primaryXAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        autoScrollingDelta: 50,
        interval: 10,
        minimum: 0,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
          minimum: _minY,
          maximum: isChecked1 == true ? 270.0 : 5.0,
          // maximum: _maxY,isChecked1
          interval: 30,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      series: <LineSeries<ChartSampleData, int>>[
        LineSeries<ChartSampleData, int>(
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          width: 2,
          name: 'FRP',
          // markerSettings: const MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartSampleData, int>(
          dataSource: chartData,
          width: 2,
          name: 'SPEED',
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
          // markerSettings: const MarkerSettings(isVisible: true),)
        ),
        LineSeries<ChartSampleData, int>(
            dataSource: chartData,
            width: 0,
            name: 'VFRP',
            xValueMapper: (ChartSampleData sales, _) => sales.x,
            yValueMapper: (ChartSampleData sales, _) => sales.thirdSeriesYValue,
            isVisibleInLegend: false,
            opacity: 0.0
            // markerSettings: const MarkerSettings(isVisible: true),)
            ),
      ],
      zoomPanBehavior: _zoomPan,

      /// To set the track ball as true and customized trackball behaviour.
      trackballBehavior: TrackballBehavior(
        enable: true,
        markerSettings: TrackballMarkerSettings(
          markerVisibility: _showMarker
              ? TrackballVisibilityMode.visible
              : TrackballVisibilityMode.hidden,
          height: 10,
          width: 10,
          borderWidth: 1,
        ),
        hideDelay: duration * 1000,
        activationMode: ActivationMode.longPress,
        tooltipAlignment: _alignment,
        tooltipDisplayMode: _mode,
        tooltipSettings: InteractiveTooltip(
          // format: _mode != TrackballDisplayMode.groupAllPoints
          //     ? 'series.name : point.y'
          //     : null,
          format: 'series.name : point.y',
          canShowMarker: canShowMarker,
        ),
        shouldAlwaysShow: showAlways,
      ),
    );
  }

  ///Continously updating the data source based on timer
  void _updateDataSource() {
    if (isrunning == true) {
      chartData.add(ChartSampleData(
          x: count,
          y: valueFRT,
          secondSeriesYValue: (speed).toInt(),
          thirdSeriesYValue: vfrp));
      // )

      count = count + 1;
    }
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min);
  }

  @override
  void dispose() {
    chartData.clear();
    _chartSeriesController = null;
    dataTx?.cancel();

    super.dispose();
  }
}

class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}

/// Chart Sales Data
class SalesData {
  /// Holds the datapoint values like x, y, etc.,
  SalesData(this.x, this.y, [this.date, this.color]);

  /// X value of the data point
  final dynamic x;

  /// y value of the data point
  final dynamic y;

  /// color value of the data point
  final Color? color;

  /// Date time value of the data point
  final DateTime? date;
}
