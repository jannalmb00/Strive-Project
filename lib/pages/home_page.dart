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
import 'package:table_calendar/table_calendar.dart';

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

  // edit task
  void startEdit(Task task) async{
    final bool? shouldRefresh = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TaskEventForm(isPersonalTask: true, task: task,) )
    );
    if(shouldRefresh != null){
      handleRefresh(shouldRefresh);
    }
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

        _fetchTask();
        _fetchEvent();
      });
    }
  }

  void viewTask(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: ListView(
            children: [
              // Title
              Text(
                "Task Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),

              // Task title
              Text(
                "Title: ${task.title}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              // Task description
              Text(
                "Description: ${task.description ?? 'No description'}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),

              // Priority level
              Text(
                "Priority Level: ${task.priorityLevel ?? 'No priority'}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),

              // Time
              Text(
                "Time: ${task.time?.isEmpty ?? true ? 'No Input' : task.time}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),

              // Date
              Text(
                "Date: ${task.date?.isEmpty ?? true ? 'No Input' : task.date}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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

          List<Task> incompleteTasks = tasks!.where((task) {
            bool isIncomplete = !task.status;
            bool matchesPriority = (_selectedPriority == 'All') ||
                (task.priorityLevel == _selectedPriority);
            bool isAfterToday = task.date == null ||
                DateTime.parse(task.date!).isAfter(
                    DateTime.now().copyWith(hour: 0, minute: 0, second: 0));
            return isIncomplete && matchesPriority && isAfterToday;
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            itemCount: incompleteTasks.length,
            itemBuilder: (BuildContext context, int index) {
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        try {
                          await taskService.deletePersonalTask(
                              incompleteTasks[index].id);
                          setState(() {
                            tasks!.remove(incompleteTasks[index]);
                          });
                          _showSnackBar(context, 'Task deleted');
                        } catch (e) {
                          _showSnackBar(context, 'Error deleting task: $e');
                        }
                      },
                      icon: Icons.delete,
                      label: 'Delete',
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        startEdit(incompleteTasks[index]);
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
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child:GestureDetector(
                    onTap: (){
                      viewTask(context, incompleteTasks[index]);
                    },
                    child:  ListTile(
                      leading: Checkbox(
                        value: incompleteTasks[index].status,
                        onChanged: (bool? val) async {
                          setState(() {
                            incompleteTasks[index].status = val ?? false;

                            taskService.editPersonalTask(incompleteTasks[index]);
                          });

                          if(user!.email != null){
                            bool result = await AuthService().addStreak(user!.email!);
                            if (result) {
                              await taskService.editPersonalTask(incompleteTasks[index]);
                              _showSnackBar(context, "Yay! You've leveled up your streak points! Keep it going!");
                            } else {
                              // Optionally handle the case where streak increment failed
                              _showSnackBar(context, "Oops! Something went wrong. Let's try again!");
                              print("Error updating streak number. Task not updated.");
                            }

                          }
                        },
                        fillColor: MaterialStateProperty.all(Colors.white),
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
                      subtitle: Text(
                          "Priority Level: ${incompleteTasks[index].priorityLevel}"),
                    ),
                  ),
                ),
              );
            },
          );

        return const Center(child: Text('No tasks found'));
      }


  Widget _completedContainer() {
    // Filter tasks to show only incomplete ones
    List<Task> completeTasks = tasks!.where((task) {
      // First, filter based on status (completed tasks)
      bool status = task.status;

      // Filter based on priority level
      bool priorityMatch = (_selectedPriority == 'All') || (task.priorityLevel == _selectedPriority);

      return status && priorityMatch;
    }).toList();

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
            child:GestureDetector(
              onTap: (){
                viewTask(context, completeTasks[index]);
              },
              child:  ListTile(
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
          ),
        );
      },
    );
  }

  Widget _missedContainer() {
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

          if (!isSameDay(taskDateTimeToday, now) && taskDateTimeToday.isBefore(now) && task.status == false) {
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
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      itemCount: missedTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          endActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    try {
                      await taskService.deletePersonalTask(
                          missedTasks[index].id);
                      setState(() {
                        tasks!.remove(
                            missedTasks[index]); // Remove task from list
                      });
                      _showSnackBar(context, 'Task deleted');
                    } catch (e) {
                      _showSnackBar(context, 'Error deleting task: $e');
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
                    startEdit(missedTasks[index]);
                  },
                  icon: Icons.edit,
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
            child:GestureDetector(
              onTap: (){
                viewTask(context, missedTasks[index]);
              },
              child:  ListTile(
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
                subtitle: Text(
                  "Priority Level: ${missedTasks[index].priorityLevel}",
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
  }

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
                    eventEdit(upcomingEvents[index]);
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
                subtitle: Text("Date: ${upcomingEvents[index].date}"),
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
        title: Text("Welcome, $userName !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600) ,),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // calendar section
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CalendarPage(),
                            ),
                          );
                        },
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Today",
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
                  child: SfCalendar(
                    view: CalendarView.day,
                    dataSource: EventAppointmentDataSource(_appointments),
                    onTap: (details) {
                      if (details.targetElement == CalendarElement.appointment) {
                        return;
                      }
                    },
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                    ),
                  ),
                ),
              ],
            ),

            // quotes & tasks section
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // quotes
                  _quotesWidgets(),
                  SizedBox(height: 30.0),
                  // tasks
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.task_rounded, color: Colors.blue, size: 30),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'TASKS',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  /*Text(
                                    "Add Task",
                                    style: TextStyle(fontSize: 15),
                                  ),*/
                                  IconButton(
                                    onPressed: () async {
                                      final bool? shouldRefresh = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TaskEventForm(isPersonalTask: true),
                                        ),
                                      );
                                      if (shouldRefresh != null) {
                                        handleRefresh(shouldRefresh);
                                      }
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
                ],
              ),
            ),

            // add task button
            /*Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        "Add Task",
                        style: TextStyle(fontSize: 15),
                      ),
                      IconButton(
                        onPressed: () async {
                          final bool? shouldRefresh = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TaskEventForm(isPersonalTask: true),
                            ),
                          );
                          if (shouldRefresh != null) {
                            handleRefresh(shouldRefresh);
                          }
                        },
                        icon: Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ),
              ],
            ),*/
            _segmentedButtonWidget(),
            SizedBox(height: 20.0),
            Text(_selectedPriority),
            _priorityDropdown(),

            // list of tasks
            SizedBox(height: 20.0),
            Flexible(
              child: tasks == null
                  ? Center(child: CircularProgressIndicator())
                  : tasks!.isEmpty
                  ? Center(child: Text('No tasks available'))
                  : _getTaskContainer(),
            ),
            SizedBox(height: 30.0),

            // events section
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
                            /*Text(
                              "Add Event",
                              style: TextStyle(fontSize: 15),
                            ),*/
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

            // add event button
            /*Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        "Add Event",
                        style: TextStyle(fontSize: 15),
                      ),
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
            ),*/

            // list of events
            Flexible(
              child: events == null
                  ? Center(child: CircularProgressIndicator())
                  : events!.isEmpty
                  ? Center(child: Text('No events available'))
                  : _getEventsContainer(),
            ),
          ],
        ),
      ),
    );
  }
}




