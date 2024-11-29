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
  //widget
  Widget _displayGroups() {
    return userGroups.isEmpty
        ? Center(child: Text('No Groups', style: TextStyle(fontSize: 18)))
        : Flexible(
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
             Navigator.of(context).
             push(MaterialPageRoute(builder: (context) => SingleGroupPage(currentGroup: group)));
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
                    Icon(Icons.group, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      group.groupName ?? 'Unnamed Group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text( "Members: " +
                        "Members: ${group.members.join(', ')}",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Text("Personal Streak"),
            ),//Personal streak container
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Text("Grop Streak"),
            ),//group streak container
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateGroupFormPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add_box_rounded, color: Colors.blue, size: 28),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(child: _displayGroups()),
          ],
        ),
      ),
    );
  }

}
