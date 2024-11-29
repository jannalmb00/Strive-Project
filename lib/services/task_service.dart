import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//model
import 'package:strive_project/models/index.dart';
//service
import 'package:strive_project/services/index.dart';

class TaskService{
  final User? user = AuthService().currentUser;

  //ghet current userID
  String get userID => user!.uid;

  //add personal task
  Future<bool> addPersonalTask(Task task) async{
    try{
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('tasks')
          .add(task.toMap());
      return  true;
    }catch(e){
      print("Error adding task: $e");
    }
    return false;
  }

  //edit personal task
  Future<bool> editPersonalTask(Task task) async{
    try{
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
      return true;
    }catch(e){
      print("Error adding task: $e");
      return false;
    }

  }

  // delete personal task
  Future<void> deletePersonalTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  // Fetch all tasks from Firestore
  Future<List<Task>> getPersonalTasks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('tasks')
          .get();

      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }


  //group

//add group task
  Future<bool> addGroupTask(Task task, String? groupid) async{
    try{
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .collection('tasks')
          .add(task.toMap());
      return  true;
    }catch(e){
      print("Error adding task: $e");
    }
    return false;
  }

  //edit task

  Future<bool> editGroupTask(Task task, String? groupid) async{
    try{
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
      return true;
    }catch(e){
      print("Error adding task: $e");
      return false;
    }

  }
  // delete group task
  Future<void> deleteGroupTask(String groupID,Task task) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .collection('tasks')
          .doc(task.id )
          .delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
  //fetch all
  Future<List<Task>> getGroupTasks(String groupid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .collection('tasks')
          .get();

      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

}