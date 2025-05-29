import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageCubit, PageState>(
      builder: (context, state) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 550,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: CalendarViewPage(),
          ),
        );
      },
    );
  }
}

class CalendarViewPage extends StatefulWidget {
  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  final Set<DateTime> journalDates = {};
  final Map<DateTime, String> dateTitleMap = {};

  @override
  void initState() {
    super.initState();
    final pageCubit = context.read<PageCubit>();

    for (int i = 0; i < pageCubit.store.journalLength; i++) {
      final pageModel = pageCubit.store.journals.values.elementAt(i);
      if (pageModel.title.isNotEmpty) {
        final pageState = pageModel.toPageState(true);
        if (pageState.items.length > 1 || (pageState.items.length == 1 && pageState.items.elementAt(0).fullText != "")) {
          try {
            List<String> parts = pageModel.title.split("/");
            DateTime date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            final normalized = normalizeDate(date);
            journalDates.add(normalized);
            dateTitleMap[normalized] = pageModel.title;
          } catch (_) {
            // Skip malformed entries
          }
        }
      }
    }
  }

  DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String getStringTitle(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  bool isDateJournaled(DateTime day) => journalDates.contains(normalizeDate(day));

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Journal Calendar",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: screenHeight * 0.8,
              child: SfCalendar(
                view: CalendarView.month,
                initialSelectedDate: DateTime.now(),
                showNavigationArrow: true,
                showDatePickerButton: true,
                todayHighlightColor: Colors.deepPurple,
                monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                  final normalized = normalizeDate(details.date);
                  final isJournaled = isDateJournaled(normalized);

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isJournaled
                          ? Colors.indigo
                          : details.date.isBefore(DateTime.now())
                              ? Colors.grey.withValues(alpha: 0.3)
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${details.date.day}',
                          style: TextStyle(
                            color: isJournaled ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isJournaled)
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        if (!isJournaled)
                          Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  );
                },
                onTap: (calendarTapDetails) {
                  final tappedDate = calendarTapDetails.date;
                  if (tappedDate == null) return;
                  final normalized = normalizeDate(tappedDate);
                  if (dateTitleMap.containsKey(normalized)) {
                    context.read<NavigationCubit>().openPageOrJournal(dateTitleMap[normalized]!);
                    Navigator.of(context).pop();
                  } else {
                    context.read<NavigationCubit>().openJournalFromCalendar(getStringTitle(normalized));
                    Navigator.of(context).pop();
                  }
                },
                monthViewSettings: const MonthViewSettings(
                  showTrailingAndLeadingDates: false,
                  dayFormat: 'EEE',
                  showAgenda: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
