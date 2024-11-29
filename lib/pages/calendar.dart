import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strive_project/pages/home_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Meeting> meetings = <Meeting>[]; // list of all events
  List<Meeting> eventsForSelectedDay = []; // list of events scheduled on a certain day

// method to show events scheduled for selected day
  void _eventsOfSelectedDay(DateTime selectedDay) {
    setState(() {
      eventsForSelectedDay = meetings
          .where((meeting) =>
      meeting.from.year == selectedDay.year &&
          meeting.from.month == selectedDay.month &&
          meeting.from.day == selectedDay.day)
          .toList();
    });
  }

// method to display add event or add task menu
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 145,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Task'),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Add Event'),
                onTap: () async {
                  final newEvent = await Navigator.push<Meeting>(
                    context,
                    MaterialPageRoute(builder: (context) => AddEvent()),
                  );
                  if (newEvent != null) {// add event to calendar
                    addEvent(newEvent);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

// method to add a new event to calendar
  void addEvent(Meeting newEvent) {
    setState(() {
      meetings.add(newEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [

            ],
          ),
          SfCalendar(
            view: CalendarView.week,
            dataSource: MeetingDataSource(meetings),
            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment) {
                return;
              }// show events scheduled for that day
              _eventsOfSelectedDay(details.date!);
            },
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: eventsForSelectedDay.length,
                itemBuilder: (context, index) {
                  final event = eventsForSelectedDay[index];
                  return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(event.eventName),
                        subtitle: Text('${event.from.toLocal()} - ${event.to.toLocal()}'),
                        tileColor: event.background,
                      ));
                }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenu(context), // show menu
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final List<String> _priorityLevels = ['Low', 'Medium', 'High'];
  String? _selectedPriorityLevel;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final TextEditingController _subject = TextEditingController();
  late Color _color; // color changes depending on priority level

// method to determine color based on priority level
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.blue;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.blue; // default low priority
    }
  }

// method to pick date range
  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? startDate;
    DateTime? endDate;

// date range picker
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(const Duration(days: 3652)),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(begin: 0, end: 1),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (dateTimeList != null && dateTimeList.length == 2) {
      startDate = dateTimeList[0];
      endDate = dateTimeList[1];

// make sure endDate is after startDate
      if (endDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar( // show error if not
          SnackBar(
            content: Text('End date must be after start date.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else { // set start and end dates
        setState(() {
          _startDateTime = startDate;
          _endDateTime = endDate;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end dates.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _subject,
            decoration: InputDecoration(
              labelText: 'Enter title',
            ),
          ),
          DropdownButton<String>(
            value: _selectedPriorityLevel,
            hint: const Text('Please elect a priority level'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedPriorityLevel = newValue;
// color changes depending on selectedPriorityLevel
                _color = _getPriorityColor(newValue!);
              });
            },
            items: _priorityLevels // display priorityLevels
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Text(
            _selectedPriorityLevel != null
                ? 'You selected: $_selectedPriorityLevel'
                : 'No priority selected',
            style: const TextStyle(fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            child: const Text('Select Dates'),
          ),
          Text(
            'Start Date: ${_startDateTime?.toLocal() ?? 'Not selected'}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'End Date: ${_endDateTime?.toLocal() ?? 'Not selected'}',
            style: TextStyle(fontSize: 16),
          ),
          ElevatedButton(
            onPressed: () {
// if all fields are filled in
              if (_subject.text.isNotEmpty && _startDateTime != null && _endDateTime != null && _selectedPriorityLevel != null) {
// create new meeting with passed info
                final newMeeting = Meeting(
                  _subject.text,
                  _startDateTime!, // not null
                  _endDateTime!, // not null
                  _color,
                  false,
                );
                Navigator.pop(context, newMeeting); // return to calendar screen
              } else { // if not all fields are filled in , show message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save Event'),
          ),
        ],
      ),
    );
  }
}

// meetingDataSource class
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

// meeting class
class Meeting {

  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}