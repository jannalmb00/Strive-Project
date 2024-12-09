import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // calendar api
import 'package:flutter/material.dart';
//model
import 'package:raeestrivetwo/models/index.dart';
//service
import 'package:raeestrivetwo/services/index.dart';
import 'package:raeestrivetwo/services/event_service.dart';


class EventService{
  final User? user = AuthService().currentUser;
  String get userID => user!.uid; // get current userID
  Function(List<Appointment>)? onEventsUpdated; // for storing in api calendar

  void setCalendarUpdateCallback(Function(List<Appointment>) callback) {
    onEventsUpdated = callback;
  }

  // add personal task
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
        onEventsUpdated!(allAppointments);  // update the api calendar
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
        List<Event> allEvents = await getEvents();  // fetch events from firestore
        List<Appointment> allAppointments = allEvents.map((e) => e.toAppointment()).toList();
        onEventsUpdated!(allAppointments);  // update the api calendar
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
        List<Event> allEvents = await getEvents();  // fetch events from firestore
        List<Appointment> allAppointments = allEvents.map((e) => e.toAppointment()).toList();
        onEventsUpdated!(allAppointments);  // update the api calendar
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