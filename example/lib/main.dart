import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_vertical_calendar/hijri_vertical_calendar.dart';
import 'package:intl/intl.dart';

void main() => runApp(Home());

/// a simple example showing several ways this package can be used
/// to implement calendar related interfaces.
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Paged Vertical Calendar'),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(icon: Icon(Icons.calendar_today), text: 'Custom'),
                  Tab(icon: Icon(Icons.date_range), text: 'DatePicker'),
                  Tab(icon: Icon(Icons.dns), text: 'Pagination'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Custom(),
                DatePicker(),
                Pagination(useHijri: true,),
              ],
            ),
          ),
        ),
      );
}

/// simple demonstration of the calendar customizability
class Custom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HijriVerticalCalendar(
      /// customize the month header look by adding a week indicator
      monthBuilder: (context, month, year) {
        return Column(
          children: [
            /// create a customized header displaying the month and year
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                DateFormat('MMMM yyyy').format(DateTime(year, month)),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),

            /// add a row showing the weekdays
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weekText('Mo'),
                  weekText('Tu'),
                  weekText('We'),
                  weekText('Th'),
                  weekText('Fr'),
                  weekText('Sa'),
                  weekText('Su'),
                ],
              ),
            ),
          ],
        );
      },

      /// added a line between every week
      // dayBuilder: (context, date) {
      //   return Column(
      //     children: [
      //       Text(DateFormat('d').format(date)),
      //       const Divider(),
      //     ],
      //   );
      // },
    );
  }

  Widget weekText(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}

/// simple example showing how to make a basic date range picker with
/// UI indication
class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// store the selected start and end dates
  DateTime? start;
  DateTime? end;

  /// method to check wether a day is in the selected range
  /// used for highlighting those day
  bool isInRange(DateTime date) {
    // if start is null, no date has been selected yet
    if (start == null) return false;
    // if only end is null only the start should be highlighted
    if (end == null) return date == start;
    // if both start and end aren't null check if date false in the range
    return ((date == start || date.isAfter(start!)) &&
        (date == end || date.isBefore(end!)));
  }

  @override
  Widget build(BuildContext context) {
    return HijriVerticalCalendar(
      addAutomaticKeepAlives: true,
      // dayBuilder: (context, date) {
      //   // update the days color based on if it's selected or not
      //   final color = isInRange(date) ? Colors.green : Colors.transparent;

      //   return Container(
      //     color: color,
      //     child: Center(
      //       child: Text(DateFormat('d').format(date)),
      //     ),
      //   );
      // },
      // onDayPressed: (date) {
      //   setState(() {
      //     // if start is null, assign this date to start
      //     if (start == null)
      //       start = date;
      //     // if only end is null assign it to the end
      //     else if (end == null)
      //       end = date;
      //     // if both start and end arent null, show results and reset
      //     else {
      //       print('selected range from $start to $end');
      //       start = null;
      //       end = null;
      //     }
      //   });
      // },
    );
  }
}

/// simple example on how to display paginated data in the calendar and interact
/// with it.
class Pagination extends StatefulWidget {
  final bool useHijri;

  const Pagination({Key? key, required this.useHijri}) : super(key: key);
  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  /// list holding all the items we are displaying
  List<DateTime> items = [];
  DateTime _focusedDay = DateTime.now();

  /// called every time a new month is loaded
  void fetchNewEvents(int year, int month) async {
    Random random = Random();
    // this is where you would load your custom data, sync or async
    // this data does require a date so you can later filter on that
    // date
    final newItems = List<DateTime>.generate(random.nextInt(40), (i) {
      print("EVENTDATETIME $year, $month");
      return HijriCalendar().hijriToGregorian(year, month, random.nextInt(27) + 1);
      // return DateTime(year, month, random.nextInt(27) + 1);
    });

    // add to all our fetched items and update UI
    setState(() => items.addAll(newItems));
  }

  @override
  Widget build(BuildContext context) {

    Widget weekText(String text) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      );
    }
    return HijriVerticalCalendar(
      // to prevent the data from being reset every time a user loads or
      // unloads this widget
      addAutomaticKeepAlives: true,
      // initialDate: _focusedDay,
      useHijri: true,
      // endDate: DateTime(_focusedDay.year-2),
      // when the new month callback fires, we want to fetch the items
      // for this month
      onMonthLoaded: fetchNewEvents,
      // monthBuilder: (context, month, year) {
      //   String text = DateFormat('MMMM yyyy').format(DateTime(year, month));
      //   // var h_date = HijriCalendar.fromDate(DateTime(year, month));
      //   // if (widget.useHijri) {
      //   //   text = "${h_date.getLongMonthName()} (${h_date.hMonth}) ${h_date.hYear} (${month} ${year})";
      //   //   print(text);
      //   // }
      //   return Column(
      //     children: [
      //       /// create a customized header displaying the month and year
            
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Text(
      //           text,
      //           // DateFormat('MMMM yyyy').format(DateTime(year, month)),
      //           style: Theme.of(context).textTheme.headline6,
      //         ),
      //       ),

      //       /// add a row showing the weekdays
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //         child: Row(
      //           mainAxisSize: MainAxisSize.max,
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             weekText('Mo'),
      //             weekText('Tu'),
      //             weekText('We'),
      //             weekText('Th'),
      //             weekText('Fr'),
      //             weekText('Sa'),
      //             weekText('Su'),
      //           ],
      //         ),
      //       ),
      //     ],
      //   );
      // },
      dayBuilder: (context, date) {
        // from all our items get those that are supposed to be displayed
        // on this day
        final eventsThisDay = items.where((e) => e == HijriCalendar().hijriToGregorian(date.hYear, date.hMonth, date.hDay));
        var eventsPreviousDay = [];
        var eventsNextDay = [];
        if (date.hDay != 1) {
           eventsPreviousDay = items.where((e) => e == HijriCalendar().hijriToGregorian(date.hYear, date.hMonth, date.hDay - 1)).toList();
        }
        if (date.hDay != HijriCalendar().getDaysInMonth(date.hYear, date.hMonth)) {
           eventsNextDay = items.where((e) => e == HijriCalendar().hijriToGregorian(date.hYear, date.hMonth, date.hDay + 1)).toList();
        }
        // String text = DateFormat('d').format(date);
        String text = date.hDay.toString();
        // if (widget.useHijri) {
        //   var h_date = HijriCalendar.fromDate(DateTime(date.year, date.month, date.day));
        //   text = '${h_date.hDay} ${h_date.hMonth}, (${date.day},${date.month})';

        // }
        bool isInMiddle = eventsPreviousDay.length > 0 && eventsNextDay.length > 0;
        bool isOnStart = eventsPreviousDay.length == 0 && eventsNextDay.length > 0;
        bool isOnEnd = eventsPreviousDay.length > 0 && eventsNextDay.length == 0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: isInMiddle ? double.infinity : 32,
              decoration: BoxDecoration(
                color: eventsThisDay.length > 0 ? Colors.green : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              ),
              child:  Center(child: Text(text)),
            ),
           
            // for every event this day, add a small indicator dot
            // Wrap(
            //   children: eventsThisDay.map((event) {
            //     return Padding(
            //       padding: const EdgeInsets.all(1),
            //       child: CircleAvatar(
            //         radius: 5,
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   }).toList(),
            // )
          ],
        );
      },
      onDayPressed: (day) {
        // when a day is pressed we can check which events are linked to this
        // day and do something with them. e.g. open a new page
        final eventsThisDay = items.where((e) => e == HijriCalendar().hijriToGregorian(day.hYear, day.hMonth, day.hDay));
        print('items this day: $eventsThisDay');
      },
    );
  }
}
