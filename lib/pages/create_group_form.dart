import 'package:flutter/material.dart';
//service
import 'package:strive_project/services/index.dart';

class CreateGroupFormPage extends StatefulWidget {
  const CreateGroupFormPage({super.key});

  @override
  State<CreateGroupFormPage> createState() => _CreateGroupFormPageState();
}

class _CreateGroupFormPageState extends State<CreateGroupFormPage> {
  GroupService groupservice = GroupService();
  late List<String> membersEmail = [];

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  final TextEditingController addFriendController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();

  Widget _entryField(String title, TextEditingController controller,  {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
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

  //widget
  Widget _iconButtonValidator(){
    return IconButton(
      onPressed: () async {
        try {
          //_showSnackBar(context, addFriendController.text);
          bool result = await groupservice.checkUserEmail(addFriendController.text);
          //_showSnackBar(context, result.toString());
          if (result) {
            membersEmail.add(addFriendController.text);
            _showSnackBar(context, "Your friend is found");
            addFriendController.clear();

          } else {
            _showSnackBar(context, "Your friend is nt found");
            addFriendController.clear();
          }
        } catch (e) {
          _showSnackBar(context, "An error occurred. Please try again.");
        }
      },
      icon: Icon(Icons.add_box_rounded),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Settings'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              _entryField("Enter group name", groupNameController),
              _entryField("Enter Description", groupDescriptionController),
              _entryField("Enter group file name", fileNameController),
              SizedBox(height: 10,),
              Text('Press icon to add your friend'),
              Row(
                children: [
                  Expanded(
                    child: _entryField("Add friends", addFriendController),
                  ),

                  _iconButtonValidator(),

                ],
              ),SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () async{
                    if( groupNameController.text.isNotEmpty && groupDescriptionController.text.isNotEmpty && membersEmail.isNotEmpty){
                      final currentUser = AuthService().currentUser;
                      final userEmail = currentUser?.email ?? 'unknown@example.com';
                      membersEmail.add(userEmail);

                      bool result = await groupservice.createGroup(groupNameController.text, groupDescriptionController.text,fileNameController.text, membersEmail);

                      if(result){
                        _showSnackBar(context, 'Group is created successfully');

                      }else{
                        _showSnackBar(context, 'Error in creating group');
                      }

                      groupNameController.clear();
                      groupDescriptionController.clear();
                      membersEmail.clear();

                      Navigator.of(context).pop();
                    }else{
                      _showSnackBar(context, 'Error');
                    }
                  },
                  child: Text('Create')
              )

            ],
          ) ,
        ),
      ),
    );
  }
}
