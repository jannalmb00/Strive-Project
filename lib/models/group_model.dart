
class GroupModel{
  final String groupID;
  final String groupName;
  final String groupDescription;
  final String groupFileName;
  final String ownerEmail;
  final List<String> members;

  GroupModel({ required this.groupID,
              required this.groupName,
              required this.groupDescription,
              required this.groupFileName,
              required this.ownerEmail,
              required this.members});
//firestore data to object to ah
  factory GroupModel.fromfireStore(Map<String, dynamic> firestoreData) {
    return GroupModel(
      groupID: firestoreData['groupID'] ?? '',
      groupName: firestoreData['groupName'] ?? 'Unnamed Group',  // Default value
      groupDescription: firestoreData['groupDescription'] ?? 'No Description',  // Default value
      groupFileName: firestoreData['groupFileName'],
      ownerEmail: firestoreData['ownerEmail'],
      members: List<String>.from(firestoreData['members'] ?? []),
    );
  }

  //object to the firebase
  Map<String, dynamic> toMap(){
    return{
      'groupID': groupID,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupFileName': groupFileName,
      'ownerEmail': ownerEmail,
      'members': members
    };
  }


}