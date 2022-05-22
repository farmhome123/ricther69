import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class valueProvider with ChangeNotifier {
  double? value1;

  double _battery = 0;
  double _frp = 0;
  double _vfrp = 0;
  double _pfrp = 0;
  double _pvfrp = 0;
  double _speed = 0;
  double _tspeed = 0;

  double _voltalarm = 0;
  double _frpalarm = 0;
  double _vfrpalarm = 0;
  int _modetype = 0;

  int _mode = 0;
  double get speed => _speed;
  double get tspeed => _tspeed;
  double get battery => _battery;
  double get frp => _frp;
  double get vfrp => _vfrp;
  double get pfrp => _pfrp;
  double get pvfrp => _pvfrp;

  double get voltalarm => _voltalarm;
  double get frpalarm => _frpalarm;
  double get vfrpalarm => _vfrpalarm;
  int get modetype => _modetype;
  int get mode => _mode;

  set mode(int value) {
    _mode = value;
    notifyListeners();
  }
  set voltalarm(double value) {
    _voltalarm = value;
    notifyListeners();
  }

  set speed(double value) {
    _speed = value;
    notifyListeners();
  }

  set tspeed(double value) {
    _tspeed = value;
    notifyListeners();
  }

  set battery(double value) {
    _battery = value;
    notifyListeners();
  }

  set frp(double value) {
    _frp = value;
    notifyListeners();
  }

  set vfrp(double value) {
    _vfrp = value;
    notifyListeners();
  }

  set pfrp(double value) {
    _pfrp = value;
    notifyListeners();
  }

  set pvfrp(double value) {
    _pvfrp = value;
    notifyListeners();
  }

  set frpalarm(double value) {
    _frpalarm = value;
    notifyListeners();
  }

  set vfrpalarm(double value) {
    _vfrpalarm = value;
    notifyListeners();
  }

  set modetype(int value) {
    _modetype = value;
    notifyListeners();
  }

  // notifyListeners();

  // สร้างฟังก์ชันการนับ counter
  // increment(value1PRO) {
  //   value1 = value1PRO;

  //   notifyListeners();
  // }
}
