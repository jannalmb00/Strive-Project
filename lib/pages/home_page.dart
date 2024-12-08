import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
//page
import 'package:strive_project/pages/index.dart';
//service
import 'package:strive_project/services/index.dart';
//model
import 'package:strive_project/models/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = AuthService().currentUser;
  String? userName;
  Map<String, dynamic>? randomQuote;
  Set<String> selected = {'Todo'};

  // for tasks
  TaskService taskService = TaskService();
  //int? taskLen;
  List<Task>? tasks;
  //for sorting
  String _selectedPriority = 'All';

  // for events
  EventService eventService = EventService();
  List<Event>? events;
  List<Appointment> _appointments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchRandomQuotes();
    _fetchTask();
    _fetchEvent();
  }

  Future<void> _fetchUserName() async {
    if (user != null) {
      try {
        userName = await AuthService().getUserName();
        setState(() {}); // Update the UI after getting the user name
      } catch (e) {
        _showSnackBar(context, 'Error fetching user data: $e');
      }
    } else {
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<void> _fetchRandomQuotes() async{
    QuotesService quotesService = QuotesService();

    // Fetch the quote from Firebase (if already fetched today) or from the API
    await quotesService.fetchAndSaveQuote();

    // Get the quote from Firebase
    randomQuote = await quotesService.getQuoteFromFirebase();

    // Update the UI
    setState(() {
      isLoading = false;
    });

  }

  Future<void> _fetchTask() async {
    try {
      List<Task> taskData =  await taskService.getPersonalTasks();
      setState(() {
        tasks = taskData;

      });


    } catch (e) {
      _showSnackBar(context, 'Error fetching tasks: $e');
    }
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
        events = eventData;
        // convert firestore fetched events to api calendar appointments
        _appointments = eventData.map((e) => e.toAppointment()).toList();
      });
    } catch (e) {
      _showSnackBar(context, 'Error fetching events: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
  }

  void startEdit(Task task) async{
    final bool? shouldRefresh = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TaskEventForm(isPersonalTask: true, task: task,) )
    );
    if(shouldRefresh != null){
      handleRefresh(shouldRefresh);
    }
  }

  void handleRefresh(bool result){
    print("Should refresh: $result");
    if (result == true) {
      setState(() {

        _fetchTask();
      });
    }
  }

  //widgets
  Widget _quotesWidgets(){
    return randomQuote != null
        ?  Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        "\"${randomQuote!['quoteText']}\"\n- ${randomQuote!['author']}",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    )
        :CircularProgressIndicator();
  }

  Widget _segmentedButtonWidget(){
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'Todo', label: Text('Todo'), icon: Icon(Icons.task)),
        ButtonSegment(value: 'Missed', label: Text('Missed'),  icon: Icon(Icons.clear)),
        ButtonSegment(value: 'Completed', label: Text('Completed'),icon: Icon(Icons.task_alt_outlined) ),
      ],
      selected: selected,
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          selected = newSelection;
        });
      },
    );
  }


  Widget _todoContainer() {
    // Filter tasks to show only incomplete ones
    List<Task> incompleteTasks = [];

    if(_selectedPriority == 'All'){
      incompleteTasks = tasks!.where((task) => !task.status).toList();
    }else if(_selectedPriority != 'All'){
      incompleteTasks = tasks!.where((task) => !task.status && task.priorityLevel == _selectedPriority).toList();
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      itemCount: incompleteTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          endActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    try {
                      await taskService.deletePersonalTask(incompleteTasks[index].id);
                      setState(() {
                        tasks!.remove(incompleteTasks[index]); // Remove task from list
                      });
                      _showSnackBar(context, 'Task deleted');
                    } catch (e) {
                      _showSnackBar(context, 'Error deleting task: $e');
                    }
                  },
                  icon:Icons.delete,
                  label: 'Delete',
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    startEdit(incompleteTasks[index]);

                  },
                  icon:Icons.edit,
                  label: 'Edit',
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                )
              ]
          ),

          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Checkbox(
                value: incompleteTasks[index].status,
                onChanged: (bool? val) {
                  setState(() {
                    incompleteTasks[index].status = val ?? false;
                    taskService.editPersonalTask(incompleteTasks[index]);
                  });
                },
                fillColor: WidgetStateProperty.all(Colors.white),
              ),
              title: Text(
                incompleteTasks[index].title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: incompleteTasks[index].status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text("Priority Level: ${incompleteTasks[index].priorityLevel}"),
            ),
          ),
        );
      },
    );
  }

  Widget _completedContainer() {
    // Filter tasks to show only incomplete ones
    List<Task> completeTasks = tasks!.where((task) => task.status).toList();

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      itemCount: completeTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return  Slidable(
          endActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    try {
                      await taskService.deletePersonalTask(completeTasks[index].id);
                      setState(() {
                        tasks!.remove(completeTasks[index]); // Remove task from list
                      });
                      _showSnackBar(context, 'Task deleted');
                    } catch (e) {
                      _showSnackBar(context, 'Error deleting task: $e');
                    }
                  },
                  icon:Icons.delete,
                  label: 'Delete',
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (BuildContext context) async {

                  },
                  icon:Icons.edit,
                  label: 'Edit',
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                )
              ]
          ),

          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                completeTasks[index].title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: completeTasks[index].status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text("Priority Level: ${completeTasks[index].priorityLevel}"),
            ),
          ),
        );
      },
    );
  }

  Widget _missedContainer(){

    List<Task> missedTasks = tasks!.where((task) {
      try {
        // Ensure the task has either a date or time
        if ((task.date == null || task.date!.isEmpty) && (task.time == null || task.time!.isEmpty)) {
          print("No date and no time");
          return false; // Skip tasks without both date and time
        }

        DateTime now = DateTime.now();

        // If task has only a time
        if (task.date == null || task.date!.isEmpty) {
          DateFormat timeFormat = DateFormat("hh:mm a");
          DateTime taskTime = timeFormat.parse(task.time!);

          // Create a DateTime object for today with the task's time
          DateTime taskDateTimeToday = DateTime(now.year, now.month, now.day, taskTime.hour, taskTime.minute);

          print("Task time (today): $taskDateTimeToday");
          print("Now: $now");
          print("Status: ${ task.status == false}");

          if (taskDateTimeToday.isBefore(now) &&task.status == false) {
            return (_selectedPriority == 'All') || (task.priorityLevel == _selectedPriority || task.status == false);
          } else {
            return false; // Task time is after now
          }
        }

        // If task has only a date
        if (task.time == null || task.time!.isEmpty) {
          DateFormat dateFormat = DateFormat("yyyy-MM-dd");
          DateTime taskDate = dateFormat.parse(task.date!);

          print("Task date: $taskDate");
          print(task.title);
          print("Now: $now");
          print("Status: ${ task.status == false}");

          if (taskDate.isBefore(now) &&task.status == false) {
            return (_selectedPriority == 'All') || (task.priorityLevel == _selectedPriority  ) ;
          } else {
            return false; // Task date is after today
          }
        }

        // If task has both date and time
        String taskDateTimeString = "${task.date!} ${task.time!}";
        DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd hh:mm a");
        DateTime taskDateTime = dateTimeFormat.parse(taskDateTimeString);

        print("Task datetime: $taskDateTime");
        print("Now: $now");
        print("Status: ${ task.status != false}");

        if (taskDateTime.isBefore(now) && task.status == false) {
          return (_selectedPriority == 'All') || (task.priorityLevel == _selectedPriority || task.status == false);
        } else {
          return false; // Task datetime is after now
        }
      } catch (e) {
        print("Error parsing task date/time: $e");
        return false; // Skip tasks with invalid date/time format
      }
    }).toList();


    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: missedTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return  Slidable(
          endActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    try {
                      await taskService.deletePersonalTask(missedTasks[index].id);
                      setState(() {
                        tasks!.remove(missedTasks[index]); // Remove task from list
                      });
                      _showSnackBar(context, 'Task deleted');
                    } catch (e) {
                      _showSnackBar(context, 'Error deleting task: $e');
                    }
                  },
                  icon:Icons.delete,
                  label: 'Delete',
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    startEdit(missedTasks[index]);

                  },
                  icon:Icons.edit,
                  label: 'Edit',
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                )
              ]
          ),

          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: GestureDetector(
              onTap: () => viewTask(context,missedTasks[index] ),
              child: ListTile(
                title: Text(
                  missedTasks[index].title,
                  style: TextStyle(
                      fontSize: 18,
                      decoration: missedTasks[index].status
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: Colors.red
                  ),
                ),
                subtitle: Text("Priority Level: ${missedTasks[index].priorityLevel}",
                  style: TextStyle(color: Colors.red),),
                trailing: Text(missedTasks[index].date.toString(),
                  style: TextStyle(
                      color: Colors.red
                  ),),
              ),
            ),
          ),
        );
      },
    );


  Widget _getTaskContainer() {
    if (selected.contains('Todo')) {
     // _showSnackBar(context, tasks!.length.toString());
      return _todoContainer();  // Return the Todo container
    } else if (selected.contains('Missed')) {
      return _missedContainer();// Call and return the completed container
    } else if (selected.contains('Completed')){
      return _completedContainer();

    }
    else {
      return Center(child: Text('No tasks available'));
    }
  }

  Widget _getEventsContainer() {
    if (_fetchEvent() == null || events!.isEmpty) {
      return Center(child: Text('No events available.'));
    }

    List<Event> upcomingEvents = events!.where((event) => event.status == false).toList();

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      itemCount: upcomingEvents.length,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) async {
                  try {
                    await eventService.deleteEvent(upcomingEvents[index].id);
                    setState(() {
                      events!.removeWhere((event) => event.id == upcomingEvents[index].id);
                      // update calendar after deleting event
                      _appointments = events!.map((e) => e.toAppointment()).toList();
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
                upcomingEvents[index].title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: upcomingEvents[index].status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text("Priority Level: ${upcomingEvents[index].priorityLevel}"),
            ),
          ),
        );
      },
    );
  }


  Widget _priorityDropdown(){
    final priorities = ['All', 'High', 'Mid', 'Low'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedPriority,
        items: priorities
            .map((priority) =>
            DropdownMenuItem(value: priority, child: Text(priority)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedPriority = value!;

          });
        },
        decoration: InputDecoration(labelText: "Filter by Priority"),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName !"),
      ),
      body: SingleChildScrollView(
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => CalendarPage()),
                            );
                          },
                          icon: Icon(Icons.calendar_month)
                      ),
                    ]),
                ),
                Text("Today",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: 250,
                    minWidth: 200,
                    minHeight: 200,
                  ),
                  child:
                  SfCalendar(
                    view: CalendarView.day,
                    dataSource: EventAppointmentDataSource(_appointments),
                    onTap: (details) {
                      if (details.targetElement == CalendarElement.appointment) {
                        return;
                      }
                      // show events scheduled for that day
                      //_eventsOfSelectedDay(details.date!);
                    },
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding:
            EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _quotesWidgets(),
                  SizedBox(height: 30.0),
                  Text("Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ]
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                    padding:  EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Text(
                        "Tasks",
                    style: TextStyle(fontSize: 15),
                    ),
                    IconButton(
                        onPressed: () async{
                          final bool? shouldRefresh = await  Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => TaskEventForm(isPersonalTask: true) )
                          );
                          if (shouldRefresh != null) {
                            handleRefresh(shouldRefresh);
                          }

                        },
                        icon: Icon(Icons.add_circle)
                    ),

                  ],
                ),
                )
              ],
            ),
            _segmentedButtonWidget(),
            SizedBox(height: 20.0),
            Text(_selectedPriority),
            _priorityDropdown(),
            Text(AuthService().currentUser!.uid),
            SizedBox(height: 20.0),
            Flexible(
                child: tasks == null
                    ? Center(child: CircularProgressIndicator())
                    : tasks!.isEmpty
                    ? Center(child: Text('No tasks available'))
                    : _getTaskContainer()
            ),
            SizedBox(height: 30.0),
            Text("Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                child:
                  Row(
                  children: [
                    Text(
                        "Events",
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
            ),
            Flexible(
                child: events == null
                    ? Center(child: CircularProgressIndicator())
                    : events!.isEmpty
                    ? Center(child: Text('No events available'))
                    : _getEventsContainer()
            )
          ],
        ),
      ),

    );
  }
}

