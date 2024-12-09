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
      Navigator.pop(context);
      //reloadPage();
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
  
  
  Future<void> deleteFile(Reference file) async {
    try {
      // Delete the file from Firebase Storage
      await file.delete();

      // After deleting the file, refresh the file list by setting the futureFiles again
      setState(() {
        futureFiles = FirebaseStorage.instance
            .ref('files/${widget.currentGroup.groupFileName}/')
            .listAll(); // Reload the file list
      });

      reloadPage();

      // Show a success message
      _showSnackBar(context, 'File deleted successfully');
    } catch (e) {
      // Handle any errors
      _showSnackBar(context, 'Error deleting file: $e');
    }
  }
  
  void reloadPage(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FileListPage(currentGroup: widget.currentGroup)),
    );
  }


  void _showAddFile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity, // Ensures the bottom sheet takes full width
          padding: EdgeInsets.all(16), // Adds padding for inner content
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display selected file name if available
              if (pickedFile != null)
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      pickedFile!.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: selectFile,
                icon: Icon(Icons.attach_file),
                label: Text('Select a File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: uploadFile,
                icon: Icon(Icons.upload),
                label: Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
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
      appBar: AppBar(
        title: Text('Files lists'),
      ),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => launchWebsiteURL(file),
                          icon: Icon(Icons.link_outlined),
                        ),
                        IconButton(
                          onPressed: () => deleteFile(file),  // Add delete functionality here
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFile(context),
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.add_box_rounded, color: Colors.white),
      ),
    );
  }
}
