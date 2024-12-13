import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/poll_model.dart';
import 'package:tripify/view_models/conversation_view_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class CreatePollPage extends StatefulWidget {
  final String currentUserId;
  final ConversationModel conversation;
  const CreatePollPage(
      {Key? key, required this.currentUserId, required this.conversation})
      : super(key: key);

  @override
  _CreatePollPageState createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  // Add any required state variables here
  String pollQuestion = '';
  List<String> options = [''];
  final _formKey = GlobalKey<FormBuilderState>();
  FirestoreService _firestoreService = FirestoreService();
  ConversationViewModel conversationViewModel = ConversationViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'question',
                decoration: const InputDecoration(
                  labelText: 'Poll Question',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'option${index + 1}',
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (options.length > 1) {
                                setState(() {
                                  options.removeAt(index);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 159, 118, 249),
                    onPressed: () {
                      setState(() {
                        options.add('');
                      });
                    },
                    child: const Text('Add Option', style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 16),
                  MaterialButton(
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 159, 118, 249),
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final formValues = _formKey.currentState?.value;
                        // Generate a map of options from the list
                        final List<String> optionList = [];
                        for (int i = 0; i < options.length; i++) {
                          optionList.add(formValues!['option${i + 1}']);
                        }
                        final poll = PollModel(
                            createdBy: widget.currentUserId,
                            id: '',
                            createdAt: DateTime.now(),
                            endAt:
                                DateTime.now().add(const Duration(hours: 24)),
                            options: optionList,
                            question: formValues?['question'] ?? '',
                            answers: null);

                        await conversationViewModel.sendPollMessage(
                            poll: poll, conversation: widget.conversation);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Create Poll',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void craetePoll() {}
}
