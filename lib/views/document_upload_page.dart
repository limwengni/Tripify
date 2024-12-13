import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/views/document_image_preview.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentUploadPage extends StatefulWidget {
  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  bool isLatestFirst = true;

  List<Map<String, dynamic>> documents = [];

  // Fetch documents from Firebase
  Future<void> fetchDocuments({bool latestFirst = true}) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final docsSnapshot = await FirebaseFirestore.instance
        .collection('Document')
        .where('user_id', isEqualTo: currentUserId)
        .orderBy('created_at', descending: latestFirst)
        .get();

    List<Map<String, dynamic>> tempDocuments = [];

    for (var doc in docsSnapshot.docs) {
      String fileUrl = doc['url'] as String;
      String fileName = doc['name'] as String;

      // Get the file reference
      Reference ref = storage.refFromURL(fileUrl);

      // Fetch the MIME type using getMetadata
      try {
        FullMetadata metadata = await ref.getMetadata();
        String mimeType = metadata.contentType ?? 'unknown';

        tempDocuments.add({
          'url': fileUrl,
          'name': fileName,
          'mimeType': mimeType,
        });
      } catch (e) {
        print('Error fetching metadata: $e');
      }
    }

    setState(() {
      documents = tempDocuments;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDocuments(latestFirst: isLatestFirst);
  }

  void toggleSorting() {
    setState(() {
      isLatestFirst = !isLatestFirst;
    });
    fetchDocuments(latestFirst: isLatestFirst);
  }

  // Function to pick a document
  Future<void> _pickDocument() async {
    // Use FilePicker to pick image or PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allows selection of custom files
      allowedExtensions: ['pdf', 'jpg', 'png'], // Allow image and PDF files
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      _uploadDocument(file);
    }
  }

  // Function to upload the document to Firebase Storage
  Future<void> _uploadDocument(PlatformFile file) async {
    try {
      // Upload to Firebase Storage
      String uid = FirebaseAuth.instance.currentUser!.uid;
      File documentFile = File(file.path!);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '.' +
          file.extension!;
      Reference ref = storage.ref().child('$uid/document/$fileName');
      UploadTask uploadTask = ref.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the file URL
      String fileUrl = await snapshot.ref.getDownloadURL();

      // Store the document information in Firestore
      await FirebaseFirestore.instance.collection('Document').add({
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'url': fileUrl,
        'name': fileName,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Fetch the updated list of documents
      fetchDocuments();
    } catch (e) {
      print('Error uploading document: $e');
    }
  }

  Future<String> _getPdfThumbnail(String fileUrl) async {
    try {
      final fileUrlWithProtocol =
          fileUrl.startsWith('https://') ? fileUrl : 'https://$fileUrl';

      final ref = FirebaseStorage.instance.refFromURL(fileUrlWithProtocol);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp.pdf');

      await ref.writeToFile(tempFile);

      PdfDocument document = await PdfDocument.openFile(tempFile.path);

      if (document.pageCount <= 0) {
        throw Exception("PDF does not contain any pages.");
      }

      PdfPage page = await document.getPage(1);

      PdfPageImage pageImage = await page.render();

      await pageImage.createImageIfNotAvailable();

      final image = await pageImage.createImageDetached();
      final pngData = await image.toByteData(format: ui.ImageByteFormat.png);

      final thumbnailFile = File('${tempDir.path}/thumbnail.png');
      await thumbnailFile.writeAsBytes(pngData!.buffer.asUint8List());

      document.dispose();

      return thumbnailFile.path;
    } catch (e) {
      print("Error generating PDF thumbnail: $e");
      return '';
    }
  }

  Future<void> _deleteDocument(String url) async {
    try {
      // Delete document from Firebase Storage
      Reference ref = storage.refFromURL(url);
      await ref.delete();

      // Delete the document record from Firestore
      await FirebaseFirestore.instance
          .collection('Document')
          .where('url', isEqualTo: url)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Fetch the updated list of documents
      fetchDocuments();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Widget _buildDocumentPreview(
      String fileUrl, String fileName, String mimeType) {
    if (mimeType.startsWith('image/')) {
      return GestureDetector(
          onTap: () {
            _showImagePreview(fileUrl, fileName);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: double.infinity,
              height: 110,
              child: Image.network(
                fileUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ));
    } else if (mimeType == 'application/pdf') {
      return GestureDetector(
          onTap: () {
            _viewPdf(fileUrl, fileName);
          },
          child: FutureBuilder<String>(
            future: _getPdfThumbnail(fileUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Image.file(
                    File(snapshot.data!),
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Icon(Icons.picture_as_pdf, color: Colors.red);
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ));
    } else {
      return Icon(Icons.insert_drive_file);
    }
  }

  void _showImagePreview(String fileUrl, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentImagePreview(imageUrl: fileUrl, fileName: fileName),
      ),
    );
  }

  void _viewPdf(String filePath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(filePath: filePath, fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                String documentUrl = documents[index]['url']!;
                String fileName = documents[index]['name']!;
                String mimeType = documents[index]['mimeType']!;

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              mimeType.startsWith('image/')
                                  ? Icon(Icons.image, color: Colors.red)
                                  : mimeType == 'application/pdf'
                                      ? Icon(Icons.picture_as_pdf,
                                          color: Colors.red)
                                      : Icon(Icons
                                          .insert_drive_file), // Default icon for other types

                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fileName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Delete icon
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteDocument(documentUrl),
                              ),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: _buildDocumentPreview(
                            documentUrl, fileName, mimeType),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickDocument,
        child: Icon(Icons.upload_file),
        tooltip: 'Upload Document',
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final String filePath;
  final String fileName;

  PDFScreen({required this.filePath, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: SfPdfViewer.network(
        filePath,
        enableDoubleTapZooming: true,
        scrollDirection: PdfScrollDirection.vertical,
      ),
    );
  }
}
