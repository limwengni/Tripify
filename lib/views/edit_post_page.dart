import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/view_models/post_provider.dart';

class EditPostPage extends StatefulWidget {
  final String postId;

  EditPostPage({required this.postId});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _descriptionController;
  final FocusNode _descFocusNode = FocusNode();
  late Post _post;

  bool _isLoading = false;
  bool _isError = false;

  // Fetch the post data from Firestore
  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _fetchPost();
  }

  // Fetch the post from Firestore
  Future<void> _fetchPost() async {
    PostProvider postProvider = new PostProvider();

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final post = await postProvider.fetchPostById(widget.postId);
      _post = post;
      String descFromFirebase = _post.description ?? '';
      _descriptionController.text = descFromFirebase.replaceAll(r'\n', '\n');
    } catch (e) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the post in Firestore
  Future<void> _updatePost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PostProvider().updatePostDescription(widget.postId, _descriptionController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Post updated!', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 159, 118, 249),
      ));
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update post.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Post')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isError) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Post')),
        body: Center(child: Text('Error loading post data')),
      );
    }

    return GestureDetector(
        onTap: () {
          // Unfocus when tapping anywhere outside the form
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(title: Text('Edit Post')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  cursorColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descFocusNode,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter a description...',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updatePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                  ),
                  child: Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ));
  }
}
