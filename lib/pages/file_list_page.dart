import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

//pages
import 'package:strive_project/models/group_model.dart';

class FileListPage extends StatefulWidget {
  final GroupModel currentGroup;
  const FileListPage({super.key, required this.currentGroup});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  PlatformFile? pickedFile;// file picker

  late Future<ListResult> futureFiles;


  @override
  void initState() {
    String groupFileName = widget.currentGroup.groupFileName;
    futureFiles = FirebaseStorage.instance.ref('files${groupFileName}/').listAll();
  }

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });

  }

  Future<void> launchWebsiteURL(Reference ref) async {
    final url = await ref.getDownloadURL();
    final Uri uri = Uri.parse(url);

    // Try to launch the URL
    if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      print('Successfully launched the URL!');
    } else {
      print('Could not launch the URL.');
    }
  }




  Future<void> uploadFile() async {
    try {
      if (pickedFile == null) {
        print('No file selected');

        return;
      }
      //groupname
      String groupFileName = widget.currentGroup.groupFileName;

      // Define the path and file
      final path = 'files${groupFileName}/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      // Reference to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(path);

      // Optional: Add metadata
      final metadata = SettableMetadata(
        contentType: 'application/octet-stream',
        cacheControl: 'max-age=3600',
      );

      // Upload the file
      final uploadTask = ref.putFile(file, metadata);

      // Monitor upload progress or wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('File uploaded successfully. Download URL: $downloadUrl');
      setState(() {
        pickedFile = null;
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void _showAddFile(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Expanded(
            child:Column(
              children: [
                if(pickedFile != null)
                  Expanded(child:
                  Container(
                    height: 50,
                    color: Colors.blue.shade200,
                    child: Center(
                      child: Text(pickedFile!.name),
                    ),
                  )),
                ElevatedButton(
                    onPressed: selectFile,
                    child: Text('Select a file')
                ),
                ElevatedButton(
                    onPressed: uploadFile,
                    child: Text('Upload a file')
                ),

              ],
            ),
          );

        });
  }

  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:FutureBuilder<ListResult>(
          future: futureFiles,
          builder: (context, snapshot){
            if(snapshot.hasData){
              final files = snapshot.data!.items;

              return ListView.builder(
                itemCount: files.length,
                  itemBuilder: (context, index){
                  final file = files[index];

                  return ListTile(
                    title: Text(file.name),
                    trailing:
                    IconButton(
                        onPressed: () => launchWebsiteURL(file),
                        icon: Icon(Icons.link_outlined)),
                  );
                  });
            }else if(snapshot.hasError){
              _showSnackBar(context, "Error occured");
              return Center(child: Text("Error occured"),);
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: IconButton(
          onPressed: (){
            _showAddFile(context);
          },
          icon: Icon(Icons.add_box_rounded)),
    );
  }
}
