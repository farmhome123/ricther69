import 'dart:async';
import 'dart:math' as math;
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:ricther69/bluetooth/valueProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


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
  @override
  void initState() {
    _zoomPan = ZoomPanBehavior(
      // enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      // enableSelectionZooming: true,
      // zoomMode: ZoomMode.x);
    );
    _modeList =
        <String>['floatAllPoints', 'groupAllPoints', 'nearestPoint'].toList();
    _alignmentList = <String>['center', 'far', 'near'].toList();
    duration = 10;
    showAlways = false;
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
    chartData = <ChartSampleData>[
      // ChartSampleData(
      //     x: 1, y: 15, secondSeriesYValue: 39, thirdSeriesYValue: 60),
      // ChartSampleData(
      //     x: 2, y: 20, secondSeriesYValue: 30, thirdSeriesYValue: 55),
      // ChartSampleData(
      //     x: 3, y: 25, secondSeriesYValue: 28, thirdSeriesYValue: 48),
      // ChartSampleData(
      //     x: 4, y: 21, secondSeriesYValue: 35, thirdSeriesYValue: 57),
      // ChartSampleData(
      //     x: 5, y: 13, secondSeriesYValue: 39, thirdSeriesYValue: 62),
      // ChartSampleData(
      //     x: 6, y: 18, secondSeriesYValue: 41, thirdSeriesYValue: 64),
      // ChartSampleData(
      //     x: 7, y: 24, secondSeriesYValue: 45, thirdSeriesYValue: 57),
      // ChartSampleData(
      //     x: 8, y: 23, secondSeriesYValue: 48, thirdSeriesYValue: 53),
      // ChartSampleData(
      //     x: 9, y: 19, secondSeriesYValue: 54, thirdSeriesYValue: 63),
      // ChartSampleData(
      //     x: 10, y: 31, secondSeriesYValue: 55, thirdSeriesYValue: 50),
      // ChartSampleData(
      //     x: 11, y: 39, secondSeriesYValue: 57, thirdSeriesYValue: 66),
      // ChartSampleData(
      //     x: 12, y: 50, secondSeriesYValue: 60, thirdSeriesYValue: 65),
      // ChartSampleData(
      //     x: 13, y: 24, secondSeriesYValue: 60, thirdSeriesYValue: 79),
      // ChartSampleData(
      //     x: 14, y: 24, secondSeriesYValue: 60, thirdSeriesYValue: 79),
      // ChartSampleData(
      //     x: 15, y: 24, secondSeriesYValue: 60, thirdSeriesYValue: 79),
      // ChartSampleData(
      //     x: 16, y: 24, secondSeriesYValue: 60, thirdSeriesYValue: 79),
      // ChartSampleData(
      //     x: 17, y: 24, secondSeriesYValue: 60, thirdSeriesYValue: 79),
    ];

    super.initState();
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FRP DATALOGGER',
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
                  const Text(
                    '  ',
                    style: TextStyle(color: Colors.amber, fontSize: 40),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   height: 230,
                //   width: 200,
                //   child: Column(
                //     children: [
                //       TextButton(
                //           onPressed: () {},
                //           child: Text(
                //             'EN/DIS ${isrunning}',
                //             style: TextStyle(
                //                 fontSize: 20,
                //                 color: isrunning == true
                //                     ? Colors.red
                //                     : Colors.yellow),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showFRT = !showFRT;
                //             });
                //           },
                //           child: const Text(
                //             'FRP',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showVFRP = !showVFRP;
                //             });
                //           },
                //           child: const Text(
                //             'VFRP',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showSPEED = !showSPEED;
                //             });
                //           },
                //           child: Text(
                //             'SPEED',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //     ],
                //   ),
                // ),
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey,
                    // child: SfCartesianChart(
                    //   plotAreaBorderWidth: 0,
                    //   primaryXAxis: NumericAxis(
                    //     majorGridLines: const MajorGridLines(width: 0),
                    //     autoScrollingDelta: 50,
                    //   ),
                    //   primaryYAxis: NumericAxis(
                    //       axisLine: const AxisLine(width: 0),
                    //       majorTickLines: const MajorTickLines(size: 0)),
                    //   zoomPanBehavior: ZoomPanBehavior(
                    //       enablePinching: true,
                    //       zoomMode: ZoomMode.x,
                    //       enablePanning: true),
                    //   tooltipBehavior: TooltipBehavior(enable: true),
                    //   series: _getDefaultLineSeries(),
                    // ),
                    child: _buildLiveLineChart(),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon:
                          Image.asset('assets/images/datalog-page/bt-play.png'),
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
                      icon:
                          Image.asset('assets/images/datalog-page/bt-stop.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
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
                        chartData!.clear();
                        print('is ======= > clear ');
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
                          // chartData = <_ChartData>[
                          //   _ChartData(0, 0, 0),
                          // ];
                        });
                        // getdataBle();
                      },
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       ' Frp = ${context.watch<valueProvider>().frp}',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showFRT (${showFRT})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showVFRP (${showVFRP})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showSPEED (${showSPEED})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //   ],
                // ),
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
                                fontSize: 24, fontWeight: FontWeight.bold),
                          )),
                    ),
                    // Text(
                    //   'SPEED === > ${speed}',
                    //   style: TextStyle(color: Colors.pink),
                    // )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
    // return SafeArea(
    //   child: Scaffold(
    //     key: key,
    //     body: Container(
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       decoration: BoxDecoration(
    //         image: DecorationImage(
    //             image: AssetImage('assets/images/datalog-page/bg.jpg'),
    //             fit: BoxFit.cover),
    //       ),
    //       child: Column(
    //         children: [
    //           SizedBox(
    //             height: 15,
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(left: 20, right: 10),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text(
    //                   'FRP DATALOGGER',
    //                   style: TextStyle(color: Colors.amber, fontSize: 30),
    //                 ),
    //                 Container(
    //                   child: Text(
    //                     // '${context.watch<valueProvider>().battery}  V',,
    //                     'V',
    //                     style: TextStyle(color: Colors.amber, fontSize: 24),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Container(
    //               width: MediaQuery.of(context).size.width * 0.8,
    //               height: MediaQuery.of(context).size.width * 0.3,
    //               child: _buildLiveLineChart()),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Row(
    //                 children: [
    //                   IconButton(
    //                     icon: Image.asset(
    //                         'assets/images/datalog-page/bt-play.png'),
    //                     iconSize: 50,
    //                     onPressed: () {
    //                       setState(() {
    //                         isrunning = true;
    //                         print(
    //                             'is ======= > Play ===== isrunning ==== ${isrunning}');
    //                         getdataBle();
    //                       });
    //                     },
    //                   ),
    //                   IconButton(
    //                     icon: Image.asset(
    //                         'assets/images/datalog-page/bt-stop.png'),
    //                     iconSize: 50,
    //                     onPressed: () {
    //                       setState(() {
    //                         isrunning = false;
    //                         dataTx?.pause();
    //                         print(
    //                             'is ======= > Stop  isrunning ==== ${isrunning}');
    //                         // getdataBle();
    //                       });
    //                     },
    //                   ),
    //                   IconButton(
    //                     icon: Image.asset('assets/images/clear.png'),
    //                     iconSize: 50,
    //                     onPressed: () {
    //                       chartData.clear();
    //                       print('is ======= > clear ');
    //                       if (isrunning == true) {
    //                         setState(() {
    //                           isrunning = true;
    //                         });
    //                       } else {
    //                         setState(() {
    //                           isrunning = false;
    //                           dataTx!.cancel();
    //                         });
    //                       }

    //                       setState(() {
    //                         count = 0;
    //                         // chartData = <_ChartData>[
    //                         //   _ChartData(0, 0, 0),
    //                         // ];
    //                       });
    //                       // getdataBle();
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Padding(
    //                     padding: const EdgeInsets.only(right: 20),
    //                     child: TextButton(
    //                         onPressed: () {
    //                           Navigator.pop(context);
    //                         },
    //                         child: Text(
    //                           'EXIT',
    //                           style: TextStyle(
    //                               fontSize: 24, fontWeight: FontWeight.bold),
    //                         )),
    //                   ),
    //                   // Text(
    //                   //   'SPEED === > ${speed}',
    //                   //   style: TextStyle(color: Colors.pink),
    //                   // )
    //                 ],
    //               ),
    //             ],
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
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
        var provider = Provider.of<valueProvider>(context, listen: false);
        setState(() {
          speed = provider.speed;
        });
        final command = _dataParser(data).toString();
        print('data  ========= > ${command}');
        final len = command.indexOf("=");
        // #IN2=5.00$"
        if (command.contains('frp=')) {
          final resultfrp1 =
              command.substring(len + 1, command.length - 1).trim();
          var valueFRTx = double.parse(resultfrp1).toStringAsFixed(0);
          valueFRT = int.parse(valueFRTx);
          // var valueFRT2 = double.parse(resultfrp1) * 100;
          // var valueFRT3 = valueFRT2.toInt();
          // valueFRT = newMap(valueFRT3, 0, 500, 0, 100).toInt();
          // valueFRT = int.parse(resultfrp1);
          // setState(() {
          //   valueFRT = int.parse(resultfrp1);
          // });

          print('######### KUY ===> $resultfrp1');
          print('Data ------------> frp = ${valueFRTx}');

          if (isrunning == true) {
            if (resultfrp1 != null && count != 1000) {
              _updateDataSource();
              setState(() {});
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
          maximum: _maxY,
          interval: 30,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      series: <LineSeries<ChartSampleData, int>>[
        LineSeries<ChartSampleData, int>(
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          width: 2,
          name: 'FRT',
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
        activationMode: ActivationMode.singleTap,
        tooltipAlignment: _alignment,
        tooltipDisplayMode: _mode,
        tooltipSettings: InteractiveTooltip(
            format: _mode != TrackballDisplayMode.groupAllPoints
                ? 'series.name : point.y'
                : null,
            canShowMarker: canShowMarker),
        shouldAlwaysShow: showAlways,
      ),
    );
  }

  ///Continously updating the data source based on timer
  void _updateDataSource() {
    if (isrunning == true) {
      chartData.add(ChartSampleData(
          x: count, y: valueFRT, secondSeriesYValue: (speed).toInt()));
      // // chartData!.removeAt(0);
      // if (chartData!.length == 1) {
      //   chartData!.removeAt(0);
      //   _chartSeriesController?.updateDataSource(
      //     addedDataIndexes: <int>[chartData!.length - 1],
      //     removedDataIndexes: <int>[0],
      //   );
      // } else {
      //   _chartSeriesController?.updateDataSource(
      //     addedDataIndexes: <int>[chartData!.length - 1],
      //   );
      // }

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
