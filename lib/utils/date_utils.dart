import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_vertical_calendar/utils/date_models.dart';

class DateUtils {
  /// generates a [Month] object from the Nth index from the startdate
  static Month getMonth(
      HijriCalendar? minDate, HijriCalendar? maxDate, int monthPage, bool up, bool useHajri) {
    // if no start date is provided use the current date
    HijriCalendar startDate = (minDate ?? HijriCalendar.now());

    // if this is not the first month in this calendar then calculate a new
    // start date for this month
    if (monthPage > 0) {
      if (up) {
        // fetsch up: month will be subtructed
        // startDate = HijriCalendar.fromDate(DateTime(startDate.hYear, startDate.hMonth + monthPage, 1));
        // var weekDate = HijriCalendar();
        startDate.hYear = startDate.hYear;
        startDate.hMonth = startDate.hMonth+ monthPage;
        startDate.hDay = 1;
      } else {
        // fetch down: month will be added
        // if (useHajri) {
        //   var h_date = HijriCalendar.fromDate(DateTime(startDate.year, startDate.month, startDate.day));
        //   print(h_date);
        //   startDate = h_date.hijriToGregorian(h_date.hYear, h_date.hMonth - monthPage, 1);
        // } else {
          // startDate =HijriCalendar.fromDate(DateTime(startDate.hYear, startDate.hMonth - monthPage, 1));
        if (startDate.hMonth - monthPage > 0) {
          // print("REST MODULO BELLOW ZERRO ${startDate.hYear}, ${startDate.hMonth - monthPage}");
          startDate.hYear = startDate.hYear;
          startDate.hMonth = startDate.hMonth - monthPage;
          startDate.hDay = 1;
        } else {
          var modulo = 12 - (monthPage % 12);
          var rest = ((monthPage - startDate.hMonth) / 12).floor() + 1;
          // if (modi)
          if (modulo >= startDate.hMonth) {
            // print("REST MODULO BELLOW $monthPage | $modulo, $rest, ${startDate.hMonth}, ${startDate.hYear - rest}, ${startDate.hMonth + (12 - modulo)}");
            // print("REST MODULO BELLOW AFTER ZERRO ${startDate.hYear - rest}, ${startDate.hMonth + (12 - modulo)}");
            startDate.hYear = startDate.hYear - rest;
            startDate.hMonth = startDate.hMonth - (12 - modulo);
            startDate.hDay = 1;
          } else {
            if (startDate.hMonth + modulo > 12) {
              // print("REST MODULO UNDER $monthPage | $modulo, $rest, ${startDate.hMonth}, ${startDate.hYear - rest}, ${startDate.hMonth + modulo}");
              // print("REST MODULO UNDER AFTER ZERRO ${startDate.hYear - rest}, ${startDate.hMonth + modulo}");
              startDate.hYear = startDate.hYear - rest;
              startDate.hMonth = startDate.hMonth - (12 - modulo);
              startDate.hDay = 1;
            } else {
              // print("REST MODULO UNDER $monthPage | $modulo, $rest, ${startDate.hMonth}, ${startDate.hYear - rest}, ${startDate.hMonth + modulo}");
              // print("REST MODULO UNDER AFTER ZERRO ${startDate.hYear - rest}, ${startDate.hMonth + modulo}");
              startDate.hYear = startDate.hYear - rest;
              startDate.hMonth = startDate.hMonth + modulo;
              startDate.hDay = 1;
            }
            
          }
          
          
        }
        
        // }
      }
    }

    // print("START DATE $startDate");

    // find the first day of the first week in this month
    final weekMinDate = _findDayOfWeekInMonth(startDate, startDate.weekDay());

    // every week has a start and end date, calculate them once for the start
    // of the month then reuse these variables for every other week in
    // month
    HijriCalendar firstDayOfWeek = weekMinDate;
    HijriCalendar lastDayOfWeek = _lastDayOfWeek(weekMinDate);

    List<Week> weeks = [];

    // we don't know when this month ends until we reach it, so we have to use
    // an indefinate loop
    while (true) {
      // if an endDate is provided we need to check if the current week extends
      // beyond this date. if it does, cap the week to the endDate and stop the
      // loop
      // print("WEEEKS $weeks");
      if (up) {
        // fetching up
        Week week;
        if (maxDate != null && firstDayOfWeek.isBefore(maxDate.hYear, maxDate.hMonth, maxDate.hDay)) {
          week = Week(maxDate, lastDayOfWeek);
        } else {
          week = Week(firstDayOfWeek, lastDayOfWeek);
        }

        if (maxDate != null && lastDayOfWeek.isAfter(maxDate.hYear, maxDate.hMonth, maxDate.hDay)) {
          weeks.add(week);
        } else if (maxDate == null) {
          weeks.add(week);
        }
        if (week.isLastWeekOfMonth) break;
      } else {
        // fetching down
        if (maxDate != null && lastDayOfWeek.isAfter(maxDate.hYear, maxDate.hMonth, maxDate.hDay)) {
          Week week = Week(firstDayOfWeek, maxDate);
          weeks.add(week);
          break;
        }

        Week week = Week(firstDayOfWeek, lastDayOfWeek);
        if (weeks.length > 0) {
          // print("COMPARRE VALUES ${weeks[weeks.length - 1].lastDay}, ${week.lastDay}");
          // print("COMPARRE ${weeks[weeks.length - 1].lastDay != week.lastDay}");
          HijriCalendar previousWeek = weeks[weeks.length - 1].lastDay;
          // print("PREVIOUS WEEK ${previousWeek.hDay}, ${previousWeek.hMonth}, ${previousWeek.hYear}");
          // print("NEW WEEK ${week.lastDay.hDay}, ${week.lastDay.hMonth}, ${week.lastDay.hYear}");
          if (previousWeek.hDay == week.lastDay.hDay && previousWeek.hMonth == week.lastDay.hMonth && previousWeek.hYear == week.lastDay.hYear) {
          //  continue;
          } else {
            weeks.add(week);

          }
        } else {
          // print("PRIDAVAM PRVNI WEEK $week");
          weeks.add(week);
        }
        

        if (week.isLastWeekOfMonth) break;
      }

      var newDate = HijriCalendar();
        newDate.hYear = firstDayOfWeek.hYear;
        newDate.hMonth = firstDayOfWeek.hMonth;
        newDate.hDay = firstDayOfWeek.hDay + 1;

      firstDayOfWeek = newDate;
      lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);
    }

    return Month(weeks);
  }

  /// calculates the last of the week by calculating the remaining days in a
  /// standard week and evaluating if this week extends beyond the total days
  /// in that month, and capping it to the end of the month if it does
  static HijriCalendar _lastDayOfWeek(HijriCalendar firstDayOfWeek) {
    int daysInMonth = HijriCalendar().getDaysInMonth(firstDayOfWeek.hYear, firstDayOfWeek.hMonth);

    final restOfWeek = (DateTime.daysPerWeek - firstDayOfWeek.weekDay());
    var endDate = HijriCalendar();
    endDate.hYear = firstDayOfWeek.hYear;
    endDate.hMonth = firstDayOfWeek.hMonth;
    endDate.hDay = daysInMonth;
    var weekDate = HijriCalendar();
    weekDate.hYear = firstDayOfWeek.hYear;
    weekDate.hMonth = firstDayOfWeek.hMonth;
    weekDate.hDay = firstDayOfWeek.hDay + restOfWeek;
    return firstDayOfWeek.hDay + restOfWeek > daysInMonth
        ? endDate
        : weekDate;
        
    // return firstDayOfWeek.hDay + restOfWeek > daysInMonth
    //     ? DateTime(firstDayOfWeek.year, firstDayOfWeek.month, daysInMonth)
    //     : firstDayOfWeek.add(Duration(days: restOfWeek));
  }

  static HijriCalendar _findDayOfWeekInMonth(HijriCalendar date, int dayOfWeek) {

    if (date.weekDay() == DateTime.sunday) {
      return date;
    } else {
      var _check_date = HijriCalendar();
      _check_date.hYear = date.hYear;
      _check_date.hMonth = date.hMonth;
      _check_date.hDay = date.hDay - (date.weekDay() - dayOfWeek);
      return _check_date;
      // return date.subtract(Duration(days: date.weekday - dayOfWeek));
    }
  }

  // static List<int> daysPerMonth(int year) => <int>[
  //       31,
  //       _isLeapYear(year) ? 29 : 28,
  //       31,
  //       30,
  //       31,
  //       30,
  //       31,
  //       31,
  //       30,
  //       31,
  //       30,
  //       31,
  //     ];

  // /// efficient leapyear calcualtion transcribed from a C stackoverflow answer
  // static bool _isLeapYear(int year) {
  //   return (year & 3) == 0 && ((year % 25) != 0 || (year & 15) == 0);
  // }
}

extension DateUtilsExtensions on DateTime {
  // int get daysInMonth => DateUtils.daysPerMonth(year)[month - 1];

  // DateTime get nextDay => DateTime(year, month, day + 1);

  // bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  // bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  // bool isSameDay(DateTime other) =>
  //     year == other.year && month == other.month && day == other.day;

  // DateTime removeTime() => DateTime(year, month, day);
}
