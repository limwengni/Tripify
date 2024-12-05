import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class AddItineraryPage extends StatefulWidget {
  @override
  _AddItineraryPageState createState() => _AddItineraryPageState();
}

class _AddItineraryPageState extends State<AddItineraryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itineraryController;
  late TextEditingController _numberOfDaysController;
  late TextEditingController _usernameController;
  final _itineraryNameFocusNode = FocusNode();
  final _numberOfDaysFocusNode = FocusNode();
  FirestoreService firestoreService = FirestoreService();

  late String itineraryName = '';
  int numberOfDays = 1;
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, String>> members = [];
  String memberUsername = '';
  int step = 1;
  UserModel? foundUser;

  @override
  void initState() {
    super.initState();
    _itineraryController = TextEditingController(text: itineraryName);
    _numberOfDaysController =
        TextEditingController(text: numberOfDays.toString());
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _itineraryNameFocusNode.dispose();
    _itineraryController.dispose();
    _numberOfDaysFocusNode.dispose();
    _numberOfDaysController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(title: Text('Add Itinerary')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: step == 1
                ? buildStep1()
                : step == 2
                    ? buildStep2()
                    : buildStep3(),
          ),
        ));
  }

  // Step 1: Itinerary Details
  Widget buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _itineraryController,
            focusNode: _itineraryNameFocusNode,
            decoration: InputDecoration(
                labelText: 'Itinerary Name', border: OutlineInputBorder()),
            onSaved: (value) => itineraryName = value ?? '',
            validator: (value) =>
                value == null || value.isEmpty ? 'Name is required' : null,
          ),
          SizedBox(height: 30),

          // Number of Days
          Text(
            'Number of Days',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: numberOfDays > 1
                    ? () {
                        setState(() {
                          numberOfDays--;
                          _numberOfDaysController.text =
                              numberOfDays.toString();
                          _updateEndDate();
                        });
                      }
                    : null,
              ),
              Expanded(
                child: TextFormField(
                  controller: _numberOfDaysController,
                  focusNode: _numberOfDaysFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Number of days is required';
                    }
                    int? days = int.tryParse(value);
                    if (days == null) {
                      return 'You can only input numbers.';
                    }
                    if (days <= 0) {
                      return 'Number of days must be greater than 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    int? newValue = int.tryParse(value);
                    if (newValue != null && newValue > 0) {
                      setState(() {
                        numberOfDays = newValue;
                        _updateEndDate();
                      });
                    } else if (newValue != null && newValue <= 0) {
                      setState(() {
                        numberOfDays = 1;
                        _numberOfDaysController.text = numberOfDays.toString();
                        _updateEndDate();
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    numberOfDays++;
                    _numberOfDaysController.text = numberOfDays.toString();
                    _updateEndDate();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 30),

          // Start Date and End Date
          Text(
            'Start Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _pickStartDate,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                  child: Text(
                    startDate == null
                        ? 'Select Start Date'
                        : DateFormat('dd MMM yyyy').format(startDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),

          if (endDate != null) ...[
            Text(
              'End Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                DateFormat('dd MMM yyyy').format(endDate!),
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          SizedBox(height: 30),

          const Spacer(),

          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 159, 118, 249),
              padding: EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text('Next', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Step 2: Invite Members
  Widget buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
              labelText: 'Member Username', border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              memberUsername = value;
            });

            _searchUser(value);
          },
        ),
        if (foundUser != null)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Profile Picture and Username
            GestureDetector(
              onTap: () {
                setState(() {
                  if (!members.any(
                      (member) => member['username'] == foundUser?.username)) {
                    members.add({
                      'username': foundUser?.username ?? '',
                      'profilePic': foundUser?.profilePic ?? '',
                    });
                  }
                  foundUser = null;
                  memberUsername = '';
                  _usernameController.clear();
                  FocusScope.of(context).unfocus();
                });
              },
              child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5, top: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(foundUser?.profilePic ?? ''),
                        radius: 26,
                      ),
                      SizedBox(width: 16),
                      Text(foundUser?.username ?? 'Username not found',
                          style: TextStyle(fontSize: 18)),
                    ],
                  )),
            ),
          ]),
        SizedBox(height: 20),
        Text(
          'Members to Invite:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: members.map((member) {
                return Container(
                  padding: EdgeInsets.all(5),
                  margin:
                      EdgeInsets.only(bottom: 10), // Space between containers
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Space between username and icons
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(member['profilePic'] ?? ''),
                            radius: 26,
                          ),
                          SizedBox(width: 16),
                          Text(
                            member['username'] ?? 'Unknown User',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                members.remove(member);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => step = 1),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                minimumSize: Size(150, 48),
                backgroundColor: Colors.blue,
              ),
              child: Text('Back', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                minimumSize: Size(150, 48),
                backgroundColor: Color.fromARGB(255, 159, 118, 249),
              ),
              child: Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  // Step 3: Confirmation
  Widget buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary Summary',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              child: Text(
                'Itinerary Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 8),
            Text(
              ': $itineraryName',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              child: Text(
                'Start Date',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 8),
            Text(
              ': ${DateFormat('dd MMM yyyy').format(startDate!)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              child: Text(
                'End Date',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 8),
            Text(
              ': ${DateFormat('dd MMM yyyy').format(endDate!)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              child: Text(
                'Duration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 8),
            Text(
              ': ${numberOfDays > 1 ? '$numberOfDays days' : '$numberOfDays day'}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        SizedBox(height: 18),
        Text(
          'Members to Invite (${members.length}):',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: members.map((member) {
                return Container(
                  padding: EdgeInsets.all(5),
                  margin:
                      EdgeInsets.only(bottom: 10), // Space between containers
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Space between username and icons
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(member['profilePic'] ?? ''),
                            radius: 26,
                          ),
                          SizedBox(width: 16),
                          Text(
                            member['username'] ?? 'Unknown User',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => step = 2),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                minimumSize: Size(150, 48),
                backgroundColor: Colors.blue,
              ),
              child: Text('Back', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: _saveItinerary,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                minimumSize: Size(150, 48),
                backgroundColor: Color.fromARGB(255, 159, 118, 249),
              ),
              child: Text('Create Itinerary',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  void _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        startDate = selectedDate;
        _updateEndDate();
      });
    }
  }

  void _updateEndDate() {
    if (startDate != null) {
      setState(() {
        endDate = startDate!.add(Duration(days: numberOfDays - 1));
      });
    }
  }

  void _nextStep() {
    if (step == 1 && _formKey.currentState!.validate()) {
      if (startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _formKey.currentState!.save();
      setState(() {
        itineraryName = _itineraryController.text;
        endDate = startDate?.add(Duration(days: numberOfDays - 1));
        step = 2;
      });
    } else if (step == 2) {
      setState(() => step = 3);
    }
  }

  Future<void> _searchUser(String username) async {
    await firestoreService.searchUser(username);

    setState(() {
      foundUser = firestoreService.userModel;
    });
  }

  void _saveItinerary() {
    final itinerary = {
      'name': itineraryName,
      'startDate': startDate,
      'numberOfDays': numberOfDays,
      'members': members,
      'createdAt': DateTime.now(),
    };
    FirebaseFirestore.instance
        .collection('itineraries')
        .add(itinerary)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Itinerary Created')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create itinerary')),
      );
    });
  }
}
