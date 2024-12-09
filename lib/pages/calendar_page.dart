import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:raeestrivetwo/services/index.dart';
import 'package:raeestrivetwo/models/index.dart';
import 'package:raeestrivetwo/pages/index.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  EventService eventService = EventService();
  List<Event> events = [];
  List<Appointment> _appointments = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  //CalendarView currentView = CalendarView.week;

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  Future<void> _fetchEvent() async {
    eventService.setCalendarUpdateCallback((appointments) {
      setState(() {
        _appointments = appointments;
      });
    });

    try {
      // load events from firestore
      List<Event> eventData = await eventService.getEvents();
      setState(() {
        events = eventData;  // Now this will never be null
        _appointments = eventData.map((e) => e.toAppointment()).toList();
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar(context, 'Error fetching events: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black54,
      ),
    );
  }

  List<Event> _getEventsForSelectedDate() {
    DateTime formattedSelectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    return events.where((event) {
      DateTime eventDate = DateFormat("yyyy-MM-dd").parse(event.date);
      DateTime formattedEventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
      return formattedEventDate.isAtSameMomentAs(formattedSelectedDate);
    }).toList();
  }

  // edit event
  void eventEdit(Event event) async{
    final bool? shouldRefresh = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => CalendarEventForm(event: event))
    );
    if(shouldRefresh != null){
      handleRefresh(shouldRefresh);
    }
  }

  void handleRefresh(bool result){
    print("Should refresh: $result");
    if (result == true) {
      setState(() {
        _fetchEvent();
      });
    }
  }

  Widget _getEventsContainer() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return Center(child: Text('No events available.'));
    }

    List<Event> selectedDayEvents = _getEventsForSelectedDate();

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      itemCount: selectedDayEvents.length,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) async {
                  try {
                    await eventService.deleteEvent(selectedDayEvents[index].id);
                    setState(() {
                      events.removeWhere((event) => event.id == selectedDayEvents[index].id);
                      _appointments = events.map((e) => e.toAppointment()).toList();
                    });
                    _showSnackBar(context, 'Event deleted');
                  } catch (e) {
                    _showSnackBar(context, 'Error deleting event: $e');
                  }
                },
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              SlidableAction(
                onPressed: (BuildContext context) async {
                  eventEdit(selectedDayEvents[index]);
                },
                icon: Icons.edit,
                label: 'Edit',
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                selectedDayEvents[index].title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: selectedDayEvents[index].status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text("Date: ${selectedDayEvents[index].date}"),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  child: Builder(
                      builder: (context) {
                        return SfCalendar(
                          view: CalendarView.month,
                          dataSource: EventAppointmentDataSource(_appointments),
                          onTap: (details) {
                            if (details.targetElement == CalendarElement.appointment) {
                              return;
                            }
                            setState(() {
                              selectedDate = details.date!;
                            });
                          },
                          monthViewSettings: const MonthViewSettings(
                            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'EVENTS',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CalendarEventForm(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /*Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:
                  Row(
                    children: [
                      Text(
                        "Add Event",
                        style: TextStyle(fontSize: 15),
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CalendarEventForm()),
                          );
                        },
                        icon: Icon(
                          Icons.add_circle,
                        ),
                      ),
                    ],),
                ),],
            ),*/
            _getEventsContainer()
          ],
        ),
      ),
    );
  }
}
