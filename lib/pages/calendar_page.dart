import 'package:flutter/material.dart';
import 'package:mystrive/services/event_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

//service
import 'package:mystrive/services/index.dart';
//model
import 'package:mystrive/models/index.dart';

class CalendarEventForm extends StatefulWidget {
  //final bool isPersonalTask;
  //final String? groupId; //optional
  final Event? event;//optiona;

  const CalendarEventForm({super.key, this.event});

  @override
  State<CalendarEventForm> createState() => _CalendarEventFormState();
}

class _CalendarEventFormState extends State<CalendarEventForm> {
  //controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timePickerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _priorityLevel = 'Low';

  final EventService eventService = EventService();


  @override
  void initState() {
    if (widget.event != null) {
      titleController.text = widget.event!.title;
      timePickerController.text = widget.event!.time ?? '';
      descriptionController.text = widget.event!.description;
      // Set the selected day based on the task's date (if available)
      if (widget.event!.date != null && widget.event!.date!.isNotEmpty) {

        _selectedDay = DateFormat("yyyy-MM-dd").parse(widget.event!.date!);
        _focusedDay = _selectedDay;
      }
    }
  } //add task
  Future<bool> addEvent() async {
    final int numOfTasks = (await eventService.getEvents()).length;
//_showSnackBar(context, numOfTasks.toString());
    //  _showSnackBar(context,widget.groupId!);
    final String id = 'task_${numOfTasks + 1}';
    final String formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDay);

    final Event newEvent = Event(
      id: id,
      title: titleController.text,
      priorityLevel: _priorityLevel,
      description: descriptionController.text,
      date: formattedDate,
      time: timePickerController.text,
      status: false,
    );

    // Add to Firestore using TaskService
    return await eventService.addEvent(newEvent);
  }

  Future<bool> editEvent() async {
    try{

      final String formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDay);

      Event updatedEvent = Event(
          id: widget.event!.id,
          title: titleController.text,
          priorityLevel:_priorityLevel,
          date: formattedDate,
          time: timePickerController.text,
          description: descriptionController.text,
          status: widget.event!.status
      );

      return  await eventService.editEvent(updatedEvent);
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
    //if( widget.isPersonalTask){
      if(widget.event == null){
        return 'Add Event';
      }else{
        return 'Edit Event';
      }
    /*}else{
      if(widget.event == null){
        return 'Add Group Task';
      }else{
        return 'Edit Group Task';
      }
    }*/

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

    String priorityLevel = validPriorities.contains(widget.event?.priorityLevel)
        ? widget.event!.priorityLevel // Safe because we just checked it exists in validPriorities
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
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(DateTime.now().year,
                    DateTime.now().month + 1, 0), // Next month
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusDay;
                  });
                },
              ),
              Text(
                widget.event?.date != null && widget.event?.date!.isNotEmpty == true
                    ? "Selected: ${widget.event!.date}"
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

                  if(titleController.text.isEmpty || descriptionController.text.isEmpty || timePickerController.text.isEmpty){
                    _showSnackBar(context, "Please fill out all fields");
                    return;
                  }else{
                    final bool result;
                    if(widget.event == null){
                      result = await addEvent();
                    }else{
                      result = await editEvent();
                    }

                    if (result) {
                      Navigator.of(context).pop();
                    } else {
                      widget.event == null ?
                      _showSnackBar(context, "Failed to add event")
                          :
                      _showSnackBar(context, "Failed to edit event") ;

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