import 'package:flutter/material.dart';
//service
import 'package:strive_project/services/index.dart';
//mode;
import 'package:strive_project/models/index.dart';

class CreateGroupFormPage extends StatefulWidget {
  final GroupModel? group;//optiona;
   CreateGroupFormPage({super.key, this.group});

  @override
  State<CreateGroupFormPage> createState() => _CreateGroupFormPageState();
}

class _CreateGroupFormPageState extends State<CreateGroupFormPage> {
  GroupService groupservice = GroupService();
  AuthService authService = AuthService();
  late List<String> membersEmail = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.group != null){
      groupNameController.text = widget.group!.groupName;
      groupDescriptionController.text = widget.group!.groupDescription;
      fileNameController.text = widget.group!.groupFileName;
      membersEmail = List<String>.from(widget.group!.members);

    }
  }

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  final TextEditingController addFriendController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();



  Widget _entryField(String title, TextEditingController controller,  {bool isPassword = false, bool canEdit = true}) {
    return TextField(
      enabled: canEdit,
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

  void createGroup() async{
    if( groupNameController.text.isNotEmpty && groupDescriptionController.text.isNotEmpty && membersEmail.isNotEmpty && fileNameController.text.isNotEmpty){
      final currentUser = AuthService().currentUser;
      final userEmail = currentUser?.email ?? 'unknown@example.com';

      for(var member in membersEmail){
        await AuthService().addCurrentUserAsFriend(member);
      }
      membersEmail.add(userEmail);

      bool result = await groupservice.createGroup(groupNameController.text, groupDescriptionController.text,fileNameController.text, membersEmail);

      if(result){
        _showSnackBar(context, 'Group is created successfully');

      }else{
        _showSnackBar(context, 'Error in creating group');
      }

    }else{
      _showSnackBar(context, 'You must fill everything and make sure to add user :)');
    }
    clearControllers();
    Navigator.of(context).pop(true);

  }

  void editGroup() async{
    if( groupNameController.text.isNotEmpty && groupDescriptionController.text.isNotEmpty && membersEmail.isNotEmpty && fileNameController.text.isNotEmpty){
      GroupModel editGroup = GroupModel(groupID: widget.group!.groupID, groupName:widget.group!.groupName ,
          groupDescription: groupDescriptionController.text, groupFileName: widget.group!.groupFileName , members: membersEmail);
print("good");
      List<String> existingMembers = widget.group?.members ?? [];
      List<String> newMembers = membersEmail
          .where((email) => !existingMembers.contains(email))
          .toList();

      for(var member in newMembers){
        await AuthService().addCurrentUserAsFriend(member);
      }

     bool result =  await groupservice.editGroup(editGroup);
     if(result){
       _showSnackBar(context, "Group is now edited");
     }else{
       _showSnackBar(context, "Group is not edited. Sorry");
     }

    }else{
      _showSnackBar(context, 'You must fill everything :)');
    }
    clearControllers();
    Navigator.of(context).pop(true);

  }

  void clearControllers(){
    groupNameController.clear();
    groupDescriptionController.clear();
    fileNameController.clear();
    membersEmail.clear();

  }


  //widget
  Widget _iconButtonValidator(){
    return IconButton(
      onPressed: () async {
        try {
          //_showSnackBar(context, addFriendController.text);
          int? result = await groupservice.checkUserEmail(addFriendController.text);
          //_showSnackBar(context, result.toString());
          if (result != null) {// if true
            setState(() {
              membersEmail.add(addFriendController.text);//it will add it to the groupb
            });

            await authService.addFriend(addFriendController.text);// add it as my friend
            _showSnackBar(context, "A user is found");//notify the user
            addFriendController.clear();//clear

          } else {
            _showSnackBar(context, "User is not found");
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
              _entryField("Enter group name", groupNameController, canEdit: false),
              _entryField("Enter Description", groupDescriptionController),
              _entryField("Enter group file name", fileNameController,canEdit: false),
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

                    if(widget.group == null){
                      createGroup();
                    }else{
                      editGroup();

                    }

                  },
                  child: Text(widget.group == null ? 'Create' : 'Edit')
              ),
          Expanded(
            child: ListView.builder(
              itemCount: membersEmail.length,
                itemBuilder: (context, index) {
                  final currentUser = AuthService().currentUser;

                  return ListTile(
                    title: Text(membersEmail[index]),
                    trailing:membersEmail[index] != currentUser!.email
                        ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Handle delete action
                        setState(() {
                          // Remove the email from the list
                          membersEmail.removeAt(index);
                        });
                      },
                    )
                        : null,
                  );
                }
            ),
          )
            ],
          ) ,
        ),
      ),
    );
  }
}
