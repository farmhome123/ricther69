import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ricther69/Page/Home.dart';
import 'package:ricther69/bluetooth/valueProvider.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider<valueProvider>(
          create: (_) => valueProvider(),
        ),
      ], child: MyApp()),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OLED DATALOG',
      theme: ThemeData(
        fontFamily: 'Facon',
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.srirachaTextTheme(
          Theme.of(context)
              .textTheme, // ถ้าไม่ใส่ มันจะตั้งค่า Default ทุกอย่างตาม ThemeData.light().textTheme
        ),
        primaryTextTheme: GoogleFonts.srirachaTextTheme(
          Theme.of(context)
              .primaryTextTheme, // ถ้าไม่ใส่ มันจะตั้งค่า Default ทุกอย่างตาม ThemeData.light().textTheme
        ),
      ),
      home: Home(
        characteristicRX: null,
        characteristicTX: null,
      ),
    );
  }
}
