export 'seconds_to_readable.dart';

String formatDuration(int seconds) {
  if (seconds < 60) {
    return "<1 min";
  } else if (seconds < 3600) {
    int minutes = seconds ~/ 60;
    return "$minutes min${minutes > 1 ? 's' : ''}";
  } else {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return "$hours h $minutes m";
  }
}
