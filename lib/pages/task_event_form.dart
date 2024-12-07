import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

//service
import 'package:strive_project/services/index.dart';
//model
import 'package:strive_project/models/index.dart';

class TaskEventForm extends StatefulWidget {
  final bool isPersonalTask;
  final String? groupId; //optional
  final Task? task;//optiona;

  const TaskEventForm({super.key, required this.isPersonalTask, this.groupId, this.task});

  @override
  State<TaskEventForm> createState() => _TaskEventFormState();
}

class _TaskEventFormState extends State<TaskEventForm> {
  //controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timePickerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime today = DateTime.now();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _priorityLevel = 'Low';


  final TaskService taskService = TaskService();


  @override
  void initState() {
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      timePickerController.text = widget.task!.time ?? '';
      descriptionController.text = widget.task!.description;
 // Set the selected day based on the task's date (if available)
      if (widget.task!.date != null && widget.task!.date!.isNotEmpty) {

        _selectedDay = DateFormat("yyyy-MM-dd").parse(widget.task!.date!);
        _focusedDay = _selectedDay;
      }
    }
  } //add task
  Future<bool> addTask() async {
    final int numOfTasks = widget.isPersonalTask
        ? (await taskService.getPersonalTasks()).length
        : (await taskService.getGroupTasks(widget.groupId!)).length;
//_showSnackBar(context, numOfTasks.toString());
  //  _showSnackBar(context,widget.groupId!);
    final String id = 'task_${numOfTasks + 1}';
    final String formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDay);

    final Task newTask = Task(
      id: id,
      title: titleController.text,
      priorityLevel: _priorityLevel,
      description: descriptionController.text,
      date: formattedDate,
      time: timePickerController.text,
      status: false,
    );

    // Add to Firestore using TaskService
    return widget.isPersonalTask
        ? await taskService.addPersonalTask(newTask)
        : await taskService.addGroupTask(newTask, widget.groupId );
  }

  Future<bool> editTask() async {
    try{

      final String formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDay);

      Task updatedTask = Task(
          id: widget.task!.id,
          title: titleController.text,
          priorityLevel:_priorityLevel,
          date: formattedDate,
          time: timePickerController.text,
          description: descriptionController.text,
          status: widget.task!.status
      );

      return widget.isPersonalTask
          ? await taskService.editPersonalTask(updatedTask)
          : await taskService.editGroupTask(updatedTask, widget.groupId );
    }catch (e){
      _showSnackBar(context, "Edit fail");
      print("Error editing task: $e");
      return false;

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

  String buttonLabel(){
    if( widget.isPersonalTask){
      if(widget.task == null){
        return 'Add Personal Task';
      }else{
        return 'Edit Personal Task';
      }
    }else{
      if(widget.task == null){
        return 'Add Group Task';
      }else{
        return 'Edit Group Task';
      }
    }

  }

  //widget
  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _dropDown() {
    final validPriorities = ['High', 'Mid', 'Low'];

    String priorityLevel = validPriorities.contains(widget.task?.priorityLevel)
        ? widget.task!.priorityLevel // Safe because we just checked it exists in validPriorities
        : 'Low';

    return DropdownButtonFormField<String>(
      value: priorityLevel,
      items: [
        DropdownMenuItem(value: 'High', child: Text('High')),
        DropdownMenuItem(value: 'Mid', child: Text('Mid')),
        DropdownMenuItem(value: 'Low', child: Text('Low')),
      ],
      onChanged: (value) {
        setState(() {
          _priorityLevel = value!;
        });
      },
      decoration: InputDecoration(labelText: "Priority Level"),
    );
  }

  Widget _timePicker() {
    return TextField(
      controller: timePickerController,
      decoration: InputDecoration(
        label: Text('Pick Time' ),
      ),
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          setState(() {
            timePickerController.text = time.format(context);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(buttonLabel()),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _entryField("Enter Title:", titleController),
              SizedBox(height: 10),
              _dropDown(),
              TableCalendar(
                firstDay: _selectedDay,
                lastDay: DateTime.utc(DateTime.now().year,
                    DateTime.now().month + 1, 0), // Next month
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusDay) {
                  // Prevent selecting past dates
                  if (selectedDay.isBefore(DateTime.now())) {
                    // Default to today if a past date is selected
                    selectedDay = DateTime.now();
                  }

                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusDay.isAfter(DateTime.now()) ? focusDay : DateTime.now(); // Ensure focusedDay is not before today
                  });
                },
              ),
              Text(
                widget.task?.date != null && widget.task?.date!.isNotEmpty == true
                    ? "Selected: ${widget.task!.date}"
                    : "No date selected", // Fallback message when no date is selected
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _timePicker(),
              _entryField("Enter Desciption:" , descriptionController),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ) {
                    _showSnackBar(context, "Title is empty");
                    return;
                  }

                  if(titleController.text.isEmpty || descriptionController.text.isEmpty){
                    _showSnackBar(context, "Title and descript must filled");
                    return;
                  }else{
                    final bool result;
                    if(widget.task == null){
                        result = await addTask();
                    }else{
                        result = await editTask();
                    }
print(result);
                    if (result) {
                      Navigator.of(context).pop(result);
                    } else {
                      widget.task == null ?
                      _showSnackBar(context, "Failed to add task")
                          :
                      _showSnackBar(context, "Failed to edit task") ;

                    }
                  }

                },
                child: Text(buttonLabel()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
