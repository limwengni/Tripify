import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String translatedText = '';
  TextEditingController textController = TextEditingController();
  final translator = GoogleTranslator();

  // Variables for storing selected languages
  String fromLanguage = 'en'; // Default source language is English
  String toLanguage = 'es'; // Default target language is Spanish

  // List of supported languages with their full names and codes
  final Map<String, String> languageMap = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ja': 'Japanese',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'hi': 'Hindi',
  };

  Future<void> translate() async {
    var translation = await translator.translate(textController.text,
        from: fromLanguage, to: toLanguage);
    setState(() {
      translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap the content with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dropdown for selecting source language
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Translate From:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DropdownButton<String>(
                              value: fromLanguage,
                              onChanged: (String? newValue) {
                                setState(() {
                                  fromLanguage = newValue!;
                                });
                              },
                              isExpanded: true, // Ensures dropdown takes full width
                              icon: Icon(Icons.arrow_drop_down, color: Colors.black), // Arrow at the end
                              items: languageMap.keys
                                  .map<DropdownMenuItem<String>>((String code) {
                                return DropdownMenuItem<String>(
                                  value: code,
                                  child: Text(languageMap[code]!),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Enter text to translate',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 5, // Allows multi-line input
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Button to trigger translation
              MaterialButton(
                padding: const EdgeInsets.all(15),
                onPressed: translate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: const Color.fromARGB(255, 159, 118, 249),
                child: Text(
                  'Translate',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // Dropdown for selecting target language
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Translate To:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DropdownButton<String>(
                              value: toLanguage,
                              onChanged: (String? newValue) {
                                setState(() {
                                  toLanguage = newValue!;
                                });
                              },
                              isExpanded: true, // Ensures dropdown takes full width
                              items: languageMap.keys
                                  .map<DropdownMenuItem<String>>((String code) {
                                return DropdownMenuItem<String>(
                                  value: code,
                                  child: Text(languageMap[code]!),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                      TextField(
                        controller: TextEditingController(text: translatedText),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 5, // Allows multi-line input
                        enabled: false, // Makes the TextField unclickable and read-only
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
