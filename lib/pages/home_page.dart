import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Quote? randomQuote;
  Set<String> selected = {'Todo'};

  TaskService taskService = TaskService();
  //int? taskLen;
  List<Task>? tasks;
  //for sorting
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchRandomQuotes();
    _fetchTask();
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
    randomQuote = await quotesService.getRandomQoute();
    setState(() {

    });

  }

  Future<void> _fetchTask() async {
    try {
      List<Task> taskData =  await taskService.getPersonalTasks();;
      setState(() {
        tasks = taskData;
      });
    } catch (e) {
      _showSnackBar(context, 'Error fetching tasks: $e');
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

  void startEdit(Task task){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TaskEventForm(isPersonalTask: true, task: task,) )
    );
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
        " \"${randomQuote!.quoteText}\" \n - ${randomQuote!.author}",
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
    List<Task> incompleteTasks = tasks!.where((task) {
      // First, filter based on status (completed tasks)
      bool status = !task.status;

      // Filter based on priority level
      bool priorityMatch = (_selectedPriority == 'All') || (task.priorityLevel == _selectedPriority);

      bool afterDate = task.date == null || DateTime.parse(task.date!).isAfter(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0));

      return status && priorityMatch && afterDate;
    }).toList();



    return ListView.builder(
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
                    _fetchTask();
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
            child: GestureDetector(
              onTap:() => viewTask(context,incompleteTasks[index]),
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
            )
          ),
        );
      },
    );
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
              ]
          ),

          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child:GestureDetector(
              onTap:() => viewTask(context,completeTasks[index]) ,
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
            )
          ),
        );
      },
    );
  }

  Widget _MissedContainer(){

    List<Task> missedTasks = tasks!.where((task) {
      try {
        // Ensure time is not empty before parsing
        if (task.date == null || task.date!.isEmpty || task.status) {
          print("no time:");
          return false; // Skip tasks with no time
        }
        DateTime taskTime = DateTime.parse(task.date!);
        return taskTime.isBefore(DateTime.now());
      } catch (e) {
        // Skip tasks with invalid date format
        return false;
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


  }

  Widget _getTaskContainer() {
    if (selected.contains('Todo')) {
     // _showSnackBar(context, tasks!.length.toString());
      return _todoContainer();  // Return the Todo container
    } else if (selected.contains('Missed')) {
      return _MissedContainer();// Call and return the completed container
    } else if (selected.contains('Completed')){
      return _completedContainer();

    }
    else {
      return Center(child: Text('No tasks available'));
    }
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
        title: Text("Welcome, $userName"),
      ),
      body: Center(
        child: Container(

          child: Column(
            children: [
              Row(
                children: [
                IconButton(
                  onPressed: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CalendarPage())
                    );
                  },
                  icon: Icon(Icons.menu),
                ),
                ],
              ),
              _quotesWidgets(),
              Row(
                children: [
                  Text("Tasks"),
                  IconButton(
                      onPressed: (){
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => TaskEventForm(isPersonalTask: true) )
                        );
                      },
                      icon: Icon(Icons.add_box_rounded)
                  ),

                ],
              ),
              _priorityDropdown(),
              Text(_selectedPriority),
              _segmentedButtonWidget(),
              Flexible(
                child: tasks == null
                    ? Center(child: CircularProgressIndicator())
                    : tasks!.isEmpty
                    ? Center(child: Text('No tasks available'))
                    : _getTaskContainer()
              )



            ],
          ),
        ),
      ),
    );
  }
}

