import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/cashout_card_list.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double? walletAmount = 0; // Initial wallet amount
  final FirestoreService _firestoreService = FirestoreService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  UserModel? user;
  double? cashoutAmount;

  final List<String> predefinedBanks = [
    'Maybank',
    'Public Bank',
    'CIMB Bank',
    'Hong Leong Bank',
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    Map<String, dynamic>? userMap =
        await _firestoreService.getDataById('User', currentUserId);
    if (userMap != null) {
      setState(() {
        user = UserModel.fromMap(userMap, currentUserId);
        walletAmount = user?.walletCredit;
        cashoutAmount = user?.cashoutAmount;
        print(cashoutAmount);
      });
    }
  }

  Widget cashoutDialog(BuildContext context, String currentUserId,
      FirestoreService firestoreService) {
    final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16), // Add padding for better UI
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cash Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'amount',
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                ),
                const SizedBox(height: 10),
                // Replaced the TextField with FormBuilderDropdown
                FormBuilderDropdown<String>(
                  name: 'bankName',
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                  items: predefinedBanks
                      .map((bank) => DropdownMenuItem<String>(
                            value: bank,
                            child: Text(bank),
                          ))
                      .toList(),
                  onChanged: (value) {
                    print('Selected bank: $value');
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'accountNumber',
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                  ]),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'accountHolderName',
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final values = _formKey.currentState!.value;
                          try {
                            final cashoutApplicationModel =
                                CashoutApplicationModel(
                              cashoutId: '',
                              createdBy: currentUserId,
                              amount: double.parse(values['amount']),
                              accountNumber: values['accountNumber'],
                              bank: values[
                                  'bankName'], // Bank is now selected from dropdown
                              createdAt: DateTime.now(),
                              isPaid: false,
                              nameOfAcc: values['accountHolderName'],
                            );

                            await firestoreService.insertDataWithAutoID(
                              'Cashout_Applications',
                              cashoutApplicationModel.toMap(),
                            );

                            walletAmount =
                                walletAmount! - double.parse(values['amount']);

                            await firestoreService.updateField('User',
                                currentUserId, 'wallet_credit', walletAmount);

                            await firestoreService.updateField(
                                'User',
                                currentUserId,
                                'cashout_amount',
                                double.parse(values['amount']));

                            setState(() {
                              cashoutAmount = double.parse(values['amount']);
                            });
                            Navigator.of(context).pop();
                          } catch (e) {
                            print('Error while submitting: $e');
                          }
                        } else {
                          print('Validation failed');
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            walletAmount != null
                ? 'RM ${walletAmount!.toStringAsFixed(2)}'
                : 'RM 0',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (cashoutAmount == null||cashoutAmount ==0) {
                    return cashoutDialog(
                        context, currentUserId, _firestoreService);
                  } else {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Cashout amount is not available.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 159, 118, 249),
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 50,
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text(
              'Cash Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                color: Colors.grey,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                cashoutAmount != null
                    ? 'RM ${cashoutAmount!.toStringAsFixed(2)}'
                    : 'RM 0',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
             SizedBox(width: 5,), Text(
                'Cashout History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Divider(
              thickness: 1,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(child: _buildCashOutHistory())
        ],
      ),
    );
  }

  Widget _buildCashOutHistory() {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getStreamDataByField(
          collection: 'Cashout_Applications',
          field: 'created_by',
          value: currentUserId,
          orderBy: 'created_at', // Assuming you have a `created_at` field
          descending: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No Cash Out Record."),
            );
          }

          List<CashoutApplicationModel> refundPackagesList = snapshot.data!.docs
              .map((doc) => CashoutApplicationModel.fromMap(
                  doc.data() as Map<String, dynamic>))
              .toList();
          return CashoutCardList(
            cashoutList: refundPackagesList,
          );
        });
  }
}
