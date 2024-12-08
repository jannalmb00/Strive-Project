import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';  // api calendar

class Event {
  String id;
  String title;
  String priorityLevel; // Can be 'Low', 'Medium', or 'High'
  String date;          // Required field
  String time;          // Required field (time should be in the format "hh:mm a" or "HH:mm")
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

  // parse time
  DateTime get parsedTime {
    try {
      if (time.isEmpty || time == '0') {
        print("Invalid time format: $time");
        return DateFormat("HH:mm").parse("00:00");  //default midnight
      }

      DateTime parsed = DateFormat("hh:mm a").parse(time); // 12 hour parsed time
      return parsed;
    } catch (e) {
      try {
        return DateFormat("HH:mm").parse(time); // 24 hour parsed time
      } catch (e) {
        print("Error parsing time: $e");
        return DateFormat("HH:mm").parse("00:00");
      }
    }
  }

  // convert to api calendar appointment
  Appointment toAppointment() {
    // convert parsed time to start time
    DateTime startTime = DateFormat("yyyy-MM-dd").parse(date).add(Duration(hours: parsedTime.hour, minutes: parsedTime.minute));
    DateTime endTime = startTime.add(Duration(hours: 1));

    return Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: title,
      color: _getPriorityColor(),
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
        return Colors.blue; // default color
    }
  }
}

// for calendar api
class EventAppointmentDataSource extends CalendarDataSource {
  EventAppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}