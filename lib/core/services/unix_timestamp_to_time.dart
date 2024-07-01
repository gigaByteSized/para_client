export 'unix_timestamp_to_time.dart';

DateTime unixTimestampToDateTime(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
