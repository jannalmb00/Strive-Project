import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';  // api calendar
class Event {
  String id;
  String title;
  String priorityLevel; // Can be 'Low', 'Medium', or 'High'
  String date;          // Required field
  String time;          // Required field 
  String description;
  bool status;

  Event({
    required this.id,
    required this.title,
    required this.priorityLevel,
    required this.date,
    required this.time,
    required this.description,
    required this.status,
  });

  // Convert Event into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priorityLevel': priorityLevel,
      'date': date,
      'time': time,
      'description': description,
      'status': status
    };
  }

  // Convert Firestore data into an Event object
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'],
      priorityLevel: map['priorityLevel'],
      date: map['date'],
      time: map['time'] ?? '',  // Handle null time values
      description: map['description'],
      status: map['status'],
    );
  }

  // Parse time according to Firestore 
  DateTime get parsedTime {
    try {
      // Default time 
      if (time.isEmpty || time == '0') {
        print("Invalid time format: $time");
        return DateFormat("HH:mm").parse("00:00"); 
      }

      DateTime parsed = DateFormat("hh:mm a").parse(time);  // Parse time 12-hour
      return parsed;
    } catch (e) {
      try {
        return DateFormat("HH:mm").parse(time); // Parse time 24-hour 
      } catch (e) {
        print("Error parsing time: $e");
        return DateFormat("HH:mm").parse("00:00");  // Default time
      }
    }
  }

  // Convert Event to Appointment to appear in calendar api
  Appointment toAppointment() {
    // Convert time
    DateTime startTime = DateFormat("yyyy-MM-dd").parse(date).add(Duration(hours: parsedTime.hour, minutes: parsedTime.minute));
    DateTime endTime = startTime.add(Duration(hours: 1)); 

    return Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: title,
      color: _getPriorityColor(),  // Get priority level 
    );
  }


  Color _getPriorityColor() {
    switch (priorityLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue; // Default color
    }
  }
}

class EventAppointmentDataSource extends CalendarDataSource {
  EventAppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}