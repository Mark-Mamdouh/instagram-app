import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  Uint8List? _file;
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  // function to make user select an image
  void _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("create a post"),
            children: [
              // image from camera
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              // image from gallery
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("choose from gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              // cancel option
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  void postImage(String username, String uid, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String res = await FirestoreMethods().uploadPost(_descController.text, _file!, uid, username, profImage);
      if(res == "success") {
        showSnackBar(context, "posted");
        clearImage();
      } else {
        showSnackBar(context, res);
      }
      setState(() {
        _isLoading = false;
      });
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descController.dispose();
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null?  Center(
      child: IconButton(
        icon: Icon(Icons.upload),
        onPressed: () => _selectImage(context),
      ),
    )
    :
    Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        // ***************** make back arrow *****************
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: Text("post to"),
        actions: [
          TextButton(
              onPressed: () => postImage(user.username, user.uid, user.photoUrl),
              child: Text(
                "Post",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading ?
          LinearProgressIndicator()
          :
          Padding(padding: EdgeInsets.only(top: 0)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: "write a caption...",
                    border: InputBorder.none,
                  ),
                  maxLines: 8,
                ),
              ),
              SizedBox(
                height: 45,
                width: 45,
                child: AspectRatio(
                  aspectRatio: 487/451,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ],
      ),
    );
  }
}
