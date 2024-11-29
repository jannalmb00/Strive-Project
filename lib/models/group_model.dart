
class GroupModel{
  final String groupID;
  final String groupName;
  final String groupDescription;
  final String groupFileName;
  final List<String> members;

  GroupModel({ required this.groupID,
              required this.groupName,
              required this.groupDescription,
              required this.groupFileName,
              required this.members});
//firestore data to object to ah
  factory GroupModel.fromfireStore(Map<String, dynamic> firestoreData) {
    return GroupModel(
      groupID: firestoreData['groupID'] ?? '',  // Default empty string if null
      groupName: firestoreData['groupName'] ?? 'Unnamed Group',  // Default value
      groupDescription: firestoreData['groupDescription'] ?? 'No Description',  // Default value
      groupFileName: firestoreData['groupFileName'],
      members: List<String>.from(firestoreData['members'] ?? []),  // Default empty list if null
    );
  }

  //object to the firebase
  Map<String, dynamic> toMap(){
    return{
      'groupID': groupID,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupFileName': groupFileName,
      'members': members
    };
  }


}