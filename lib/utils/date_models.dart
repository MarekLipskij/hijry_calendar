import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_vertical_calendar/utils/date_utils.dart';

class Month {
  final int month;
  final int year;
  final int daysInMonth;
  final List<Week> weeks;

  Month(this.weeks)
      : year = weeks.first.firstDay.hYear,
        month = weeks.first.firstDay.hMonth,
        daysInMonth =  HijriCalendar().getDaysInMonth(weeks.first.firstDay.hYear, weeks.first.firstDay.hMonth);

  @override
  String toString() {
    return 'Month{month: $month, year: $year, daysInMonth: $daysInMonth, weeks: $weeks}';
  }
}

class Week {
  final HijriCalendar firstDay;
  final HijriCalendar lastDay;

  Week(this.firstDay, this.lastDay);

  int get duration => lastDay.hDay - firstDay.hDay;

  bool get isLastWeekOfMonth => lastDay.hDay == HijriCalendar().getDaysInMonth(lastDay.hYear, lastDay.hMonth);

  @override
  String toString() {
    return 'Week{firstDay: $firstDay, lastDay: $lastDay}';
  }
}
