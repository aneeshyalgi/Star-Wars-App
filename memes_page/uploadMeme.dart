import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class uploadMeme extends StatefulWidget {
  @override
  _uploadMemeState createState() => _uploadMemeState();
}

class _uploadMemeState extends State<uploadMeme> {
  File _imageFile;
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        // ratioX: 1.0,
        // ratioY: 1.0,
        // maxWidth: 512,
        // maxHeight: 512,
    );
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }
  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }
  void _clear() {
    setState(() => _imageFile = null);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Upload Meme"),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFF4C4B4B),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_camera, size: 30, color: Colors.red,),
              onPressed: () => _pickImage(ImageSource.camera),
              tooltip: "Take a Picture",
            ),
            IconButton(
              icon: Icon(Icons.photo_library, size: 30, color: Colors.red,),
              onPressed: () => _pickImage(ImageSource.gallery),
              tooltip: "Upload From Gallery",
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          if (_imageFile != null) ...[
            Image.file(_imageFile),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.crop, size: 30,),
                  onPressed: _cropImage,
                  tooltip: "Crop Image",
                ),
                IconButton(
                  icon: Icon(Icons.clear, size: 30,),
                  onPressed: _clear,
                  tooltip: "Clear Image",
                ),
              ],
            ),
            Uploader(file: _imageFile)
          ]
        ],
      ),
    );
  }
}
 
class Uploader extends StatefulWidget {
  final File file;
  Uploader({Key key, this.file}) : super(key: key);
  @override
  _UploaderState createState() => _UploaderState();
}
class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://starwarsapp-80c27.appspot.com');
  String filePath = 'images/${DateTime.now()}.png';
  String _downloadUrl;
  StorageUploadTask _uploadTask;
  var imageUrl;
  FirebaseUser user;
  Future <void> getUserData() async{
    FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      print(userData.email);
    });
  }
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void _startUpload() async{
    StorageUploadTask uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    //String downloadAddress = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _uploadTask = uploadTask;
      //_downloadUrl = downloadAddress;
      //print(_downloadUrl);
    });
    _saveDownloadURL();
  }

    _saveDownloadURL() async{
    String downloadAddress = await (await _uploadTask.onComplete).ref.getDownloadURL();
    Firestore.instance.collection("Memes").document()
        .setData({ 'url': downloadAddress, "views": 0, "likes" : 0, "dislikes" : 0, "userEmail": "${user?.email}",});
    mounted;
    setState(() {
      _downloadUrl = downloadAddress;
      print(_downloadUrl);
      dispose();
    });
  }
  @override
  Widget build(BuildContext context){
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;
            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;
            return Column(
              children: [
                if (_uploadTask.isComplete)
                  Text('Your Image has been uploaded', style: TextStyle(fontSize: 20),),
                if (_uploadTask.isPaused)
                  FlatButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: _uploadTask.resume,
                  ),
                if (_uploadTask.isInProgress)
                  FlatButton(
                    child: Icon(Icons.pause),
                    onPressed: _uploadTask.pause,
                  ),
                // Progress bar
                LinearPercentIndicator(
                  lineHeight: 30.0,
                  percent: progressPercent,
                  center: new Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
                  progressColor: Colors.red,
                ),
              ],
            );
          });
    } else {
      return FlatButton.icon(
        color: Colors.red,
        label: Text('Start Upload', style: TextStyle(color: Colors.black),),
        icon: Icon(Icons.cloud_upload, color: Colors.black,),
        onPressed: _startUpload,
      );
    }
  }
}


