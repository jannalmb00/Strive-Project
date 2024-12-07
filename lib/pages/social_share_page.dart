import 'package:flutter/material.dart';
import 'package:strive_project/models/group_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//page
import 'package:strive_project/pages/index.dart';
//service
 import 'package:strive_project/services/index.dart';


class SocialSharePage extends StatefulWidget {
  const SocialSharePage({super.key});

  @override
  State<SocialSharePage> createState() => _SocialSharePageState();
}

class _SocialSharePageState extends State<SocialSharePage> {

  GroupService groupservice = GroupService();
  List<GroupModel> userGroups = [];
  final currentUser = AuthService().currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async{
    try{
      String email = AuthService().currentUser?.email ?? 'unknown@example.com';
      List<Map<String, dynamic>> groups = await groupservice.fetchUserGroups(email);

      setState(() {
        userGroups = groups
            .map((groupData) => GroupModel.fromfireStore(groupData))
            .toList();
      });

    }catch(e){
      print("Error: $e");
    }
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

  Future<int> getStreakNumber() async{
    String email = currentUser?.email ?? 'unknown@example.com';
    int? result = await groupservice.checkUserEmail(email);

    return result ?? 0;
  }

  Future<void> deleteGroup(GroupModel group) async{
    try{

      await groupservice.deleteGroup(group.groupID);
      var members = group.members;

      for(var member in members){
        await AuthService().deleteFriend(member);

      }



      _fetchGroups();
    }catch(e){
      print("Error: $e");
    }

  }

  Future<List<Map<String, dynamic>>> getFriendsAndStreak() async{
    List<Map<String, dynamic>> friendsList = [];

    try{
      List<String> listOfFriends = await AuthService().getListFriends();
      String? currentUserEmail = AuthService().currentUser?.email;

      for(String email in listOfFriends){
        var streakNumber = await groupservice.checkUserEmail(email);
        friendsList.add({
          'email': email,
          'streakNumber': streakNumber ?? 0,
        });
      }
      if (currentUserEmail != null) {
        var currentUserStreak = await groupservice.checkUserEmail(currentUserEmail);
        friendsList.add({
          'email': currentUserEmail,
          'streakNumber': currentUserStreak ?? 0,
        });
      }

      return friendsList;
    }catch (e){
      print("Error fetching friends and streaks: $e");
      return [];
    }
  }

  void _showGlobalStreak(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: getFriendsAndStreak(),  // Asynchronous method call
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List<Map<String, dynamic>> friendsData = snapshot.data!;
              friendsData.sort((a, b) {
                return b['streakNumber'].compareTo(a['streakNumber']); // Sort descending
              });

              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Friends Streaks",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: friendsData.map((friendData) {
                          String email = friendData['email'];
                          int streak = friendData['streakNumber'];
                          int index = friendsData.indexOf(friendData) + 1;

                          //color
                          Color textColor = email == currentUser?.email ? Colors.redAccent : Colors.indigo;


                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${index}. ${email}",
                                  style: TextStyle(color: textColor, fontSize: 16),
                                ),
                                Text(
                                  "Streak: $streak",
                                  style: TextStyle(color: textColor, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        );
      },
    );
  }
  //widget
  Widget _displayGroups() {
    return userGroups.isEmpty
        ? Center(child: Text('No Groups', style: TextStyle(fontSize: 18)))
        : Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: userGroups.length,
        itemBuilder: (context, index) {
          final group = userGroups[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SingleGroupPage(currentGroup: group)));
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      group.groupName ?? 'Unnamed Group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateGroupFormPage(group: group),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => deleteGroup(group),
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _displayPersonalStreak(){
    return FutureBuilder<int>(
      future: getStreakNumber(),  // Asynchronous method call
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());  // Show loading while waiting
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));  // Show error if there's one
        } else if (snapshot.hasData) {
          // Display the streak number when data is available
          return Container(
            child: Center(
              child: Column(
                children: [
                  Text("Hi, your streak number is: ${snapshot.data}"),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No streak data available.'));
        }
      },
    );
  }

  Widget _displayGlobalStreak() {
    return GestureDetector(
      onTap: () => _showGlobalStreak(context),  // Trigger the modal when tapped
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color:Colors.deepPurple),

          borderRadius: BorderRadius.circular(8.0),

        ),
        child: Center(
          child: Text(
            "Global Streak",  // Text on the container

          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rankings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayPersonalStreak(),//Personal streak container
            _displayGlobalStreak(),//group streak container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final bool? shouldRefresh = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateGroupFormPage(),
                      ),
                    );
                    if (shouldRefresh == true) {
                      setState(() {

                        _fetchGroups();
                      });
                    }

                  },
                  icon: Icon(Icons.add_box_rounded, color: Colors.blue, size: 28),
                ),
              ],
            ),
            SizedBox(height: 16),
            _displayGroups()
          ],
        ),
      ),
    );
  }

}
