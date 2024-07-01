export 'convert_to_dms.dart';

String convertLatLng(double decimal, bool isLat) {
  String degree = "${decimal.toString().split(".")[0]}°";
  double minutesBeforeConversion =
      double.parse("0.${decimal.toString().split(".")[1]}");
  String minutes =
      "${(minutesBeforeConversion * 60).toString().split('.')[0]}'";
  double secondsBeforeConversion = double.parse(
      "0.${(minutesBeforeConversion * 60).toString().split('.')[1]}");
  String seconds =
      '${double.parse((secondsBeforeConversion * 60).toString()).toStringAsFixed(2)}" ';
  String dmsOutput =
      "$degree$minutes$seconds${isLat ? decimal > 0 ? 'N' : 'S' : decimal > 0 ? 'E' : 'W'}";
  return dmsOutput;
}
