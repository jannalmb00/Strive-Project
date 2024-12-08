import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // calendar api
import 'package:flutter/material.dart';
//model
import 'package:strive-project/models/index.dart';
//service
import 'package:strive-project/services/index.dart';
import 'package:strive-project/services/event_service.dart';


class EventService{
  final User? user = AuthService().currentUser;
  String get userID => user!.uid; // get current userID
  Function(List<Appointment>)? onEventsUpdated; // for storing in api calendar

  void setCalendarUpdateCallback(Function(List<Appointment>) callback) {
    onEventsUpdated = callback;
  }

  // add event
  Future<bool> addEvent(Event event) async{
    try{
      // add to firestore db
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('events')
          .add(event.toMap());

      // add to api calendar
      if (onEventsUpdated != null) {
        List<Event> allEvents = await getEvents();
        List<Appointment> allAppointments = allEvents.map((e) => e.toAppointment()).toList();
        onEventsUpdated!(allAppointments);  // Update the calendar's data
      }
      return  true;
    }catch(e){
      print("Error adding event: $e");
    }
    return false;
  }

  //edit event
  Future<bool> editEvent(Event event) async{
    try{
      // edit in firestore db
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('events')
          .doc(event.id)
          .update(event.toMap());

      // edit in api calendar
      if (onEventsUpdated != null) {
        List<Event> allEvents = await getEvents();  // fetch all events from Firestore
        List<Appointment> allAppointments = allEvents.map((e) => e.toAppointment()).toList();
        onEventsUpdated!(allAppointments);  // update calendar api
      }
      return true;
    }catch(e){
      print("Error adding event: $e");
      return false;
    }

  }

  // delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      // delete in firestore db
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('events')
          .doc(eventId)
          .delete();

      // delete in api calendar
      if (onEventsUpdated != null) {
        List<Event> allEvents = await getEvents();  // fetch all events from Firestore
        List<Appointment> allAppointments = allEvents.map((e) => e.toAppointment()).toList();
        onEventsUpdated!(allAppointments);  // update calendar api 
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // fetch all events from Firestore
  Future<List<Event>> getEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('events')
          .get();

      return snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }
}