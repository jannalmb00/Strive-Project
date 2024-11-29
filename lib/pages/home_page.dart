import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    List<Task> incompleteTasks = [];

    if(_selectedPriority == 'All'){
      incompleteTasks = tasks!.where((task) => !task.status).toList();
    }else if(_selectedPriority != 'All'){
      incompleteTasks = tasks!.where((task) => !task.status && task.priorityLevel == _selectedPriority).toList();
    }

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

  Widget _getTaskContainer() {
    if (selected.contains('Todo')) {
     // _showSnackBar(context, tasks!.length.toString());
      return _todoContainer();  // Return the Todo container
    } else if (selected.contains('Completed')) {
      return _completedContainer();  // Call and return the completed container
    } else {
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

