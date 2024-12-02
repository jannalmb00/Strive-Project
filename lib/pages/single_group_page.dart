import 'package:flutter/material.dart';
import 'package:strive_project/pages/index.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//services
import 'package:strive_project/services/index.dart';
//model
import 'package:strive_project/models/index.dart';


class SingleGroupPage extends StatefulWidget {
  final GroupModel currentGroup;

  const SingleGroupPage({super.key, required this.currentGroup});

  @override
  State<SingleGroupPage> createState() => _SingleGroupPageState();
}

class _SingleGroupPageState extends State<SingleGroupPage> {
  Set<String> selected = {'Todo'};
  TaskService taskService = TaskService();
  List<Task>? tasks;

  //for sorting
  String _selectedPriority = 'All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTask();
  }

  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
  }
  void startEdit(Task task){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TaskEventForm(isPersonalTask: false, task: task, groupId: widget.currentGroup.groupID,) )
    );
  }
  Future<void> _fetchTask() async {
    try {
      List<Task> taskData =  await taskService.getGroupTasks(widget.currentGroup.groupID);;
      setState(() {
        tasks = taskData;
      });
    } catch (e) {
      _showSnackBar(context, 'Error fetching tasks: $e');
    }
    // String tasksText = tasks!.map((task) {
    //   return 'Task ID: ${task.id}, Title: ${task.title}, Status: ${task.status ? 'Completed' : 'Pending'}, Priority: ${task.priorityLevel}';
    // }).join('\n');
    //
    // _showSnackBar(context, tasksText);

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

                      await taskService.deleteGroupTask( widget.currentGroup.groupID, incompleteTasks[index]);
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
                    taskService.editGroupTask(incompleteTasks[index],  widget.currentGroup.groupID);
                    tasks![tasks!.indexOf(incompleteTasks[index])].status = val ?? false;
                  });
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
                      await taskService.deleteGroupTask( widget.currentGroup.groupID, completeTasks[index]);
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
        title: Text("Welcome to ${widget.currentGroup.groupName} Group  " ),
      ),
      body:   Column(
              children: [
                Text(
                  "Files (${widget.currentGroup.groupFileName})",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(builder: (context) => ImageGroupPage(groupId: widget.currentGroup.groupID))
                    // );
                    Navigator.of(context).
                    push(MaterialPageRoute(builder: (context) => FileListPage(currentGroup: widget.currentGroup,)));


                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black26
                      ),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Row(
                  children: [
                    Text("Tasks"),
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>TaskEventForm(isPersonalTask: false, groupId: widget.currentGroup.groupID,) )
                          );
                        },
                        icon: Icon(Icons.add_box_rounded)
                    ),

                  ],
                ),
                _priorityDropdown(),
                _segmentedButtonWidget(),
                Flexible(
                    child: tasks == null
                        ? Center(child: CircularProgressIndicator())
                        : tasks!.isEmpty
                        ? Center(child: Text('No tasks available'))
                        : _getTaskContainer()
                ),






              ],

          ),


    );
  }
}
