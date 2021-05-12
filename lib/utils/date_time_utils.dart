import 'package:intl/intl.dart';

DateFormat formatDateOnlyMonthDay = DateFormat('d MMM');
DateFormat formatDateYearMonthDay = DateFormat('d MMM yyyy');
DateFormat formatDateMonthDay = DateFormat('d MMM, h:mm');
DateFormat formatTime = DateFormat('h:mm a');
DateFormat formatTimeDateLiveSessions = DateFormat('d MMM yyyy, h:mm a');
DateFormat formatDateLiveSessions = DateFormat('d MMM yyyy');

String parseDateTime(DateTime dateTime) {
  dateTime = dateTime.toLocal();

  final DateTime now = DateTime.now();

  final DateTime lastMidnight = DateTime(now.year, now.month, now.day);
  final DateTime beginOfThisYear = DateTime(now.year);

  if (dateTime.isAfter(lastMidnight)) {
    ///today
    return formatTime.format(dateTime);
  } else if (dateTime.isAfter(beginOfThisYear)) {
    ///this year
    return formatDateMonthDay.format(dateTime);
  } else {
    ///any other day
    return formatDateYearMonthDay.format(dateTime);
  }
}

String parseTimeOnly(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  return formatTime.format(dateTime);
}

String parseDayOnly(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  final DateTime now = DateTime.now();

  final DateTime lastMidnight = DateTime(now.year, now.month, now.day);
  final DateTime beginOfThisYear = DateTime(now.year);

  if (dateTime.isAfter(lastMidnight)) {
    ///today
    return 'Today';
  } else if (dateTime.isAfter(beginOfThisYear)) {
    ///this year
    return formatDateOnlyMonthDay.format(dateTime);
  } else {
    ///any other day
    return formatDateYearMonthDay.format(dateTime);
  }
}
