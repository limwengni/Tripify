import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/view_models/ad_provider.dart';
import 'package:tripify/models/ad_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenewAdsPage extends StatefulWidget {
  final String adId;
  final String travelPackageId;
  final int adsCredit;

  RenewAdsPage(
      {required this.adId,
      required this.travelPackageId,
      required this.adsCredit});

  @override
  _RenewAdsPageState createState() => _RenewAdsPageState();
}

class _RenewAdsPageState extends State<RenewAdsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  NewTravelPackageModel? _selectedPackage;
  String? _selectedAdType;
  int _totalPrice = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  late int currentAdsCredit;
  String? _renewalType;

  final Map<String, Map<String, dynamic>> _adPackages = {
    "3 Days": {
      "duration": 3,
      "price": 50,
      "estimatedClicks": 100,
      "estimatedImpressions": 1000,
      "flatRate": 50.0,
    },
    "7 Days": {
      "duration": 7,
      "price": 100,
      "estimatedClicks": 200,
      "estimatedImpressions": 2000,
      "flatRate": 100.0,
    },
    "1 Month": {
      "duration": 30,
      "price": 300,
      "estimatedClicks": 600,
      "estimatedImpressions": 6000,
      "flatRate": 300.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchPackage();
    currentAdsCredit = widget.adsCredit;
    print(currentAdsCredit);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPackage() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('New_Travel_Packages')
        .doc(widget.travelPackageId) // Use the passed package ID
        .get();

    if (snapshot.exists) {
      setState(() {
        _selectedPackage = NewTravelPackageModel.fromMap(
            snapshot.data() as Map<String, dynamic>);
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;

        DateTime today = DateTime.now();

        if (_startDate!.year == today.year &&
            _startDate!.month == today.month &&
            _startDate!.day == today.day) {
          _startDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            DateTime.now().hour,
            DateTime.now().minute,
          );
        } else {
          // If it's a future date, set it to 12:00 AM
          _startDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            0,
            0,
          );
        }

        // If ad type is selected, calculate the end date
        if (_selectedAdType != null) {
          _calculateEndDate();
        }
      });
    }
  }

  void _calculateEndDate() {
    if (_startDate != null && _selectedAdType != null) {
      setState(() {
        _endDate = _startDate!
            .add(Duration(days: _adPackages[_selectedAdType!]!['duration']));
      });
    }
  }

  void _submitRenewalAd() async {
    if (_selectedAdType == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_renewalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a renewal type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double cpcRate = _calculateCPC();
    double cpmRate = _calculateCPM();
    double flatRate = _calculateFlatRate();

    if (widget.adsCredit >= _totalPrice) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: Color(0xFF9F76F9))),
      );

      try {
        // Create a new advertisement with an auto-generated ID
        final newAdRef =
            FirebaseFirestore.instance.collection('Advertisement').doc();
        Advertisement newAd = Advertisement(
          id: newAdRef.id,
          packageId: widget.travelPackageId,
          adType: _selectedAdType!,
          startDate: _startDate!,
          endDate: _endDate!,
          status: 'ongoing',
          renewalType: _renewalType!,
          createdAt: DateTime.now(),
          cpcRate: cpcRate,
          cpmRate: cpmRate,
          flatRate: flatRate,
        );

        await newAdRef.set(newAd.toMap());

        // Log the ad credit transaction
        DateTime now = DateTime.now();
        await FirebaseFirestore.instance
            .collection('AdsCredTransaction')
            .doc()
            .set({
          'user_id': FirebaseAuth.instance.currentUser!.uid,
          'amount': _totalPrice,
          'created_at': now,
          'type': 'adspurchase', // Purchase of ad credit
        });

        int remainingCredits = widget.adsCredit - _totalPrice;
        await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'ads_credit': remainingCredits});

        Navigator.pop(context);
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to renew advertisement: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Not enough credit for this ad. Please top up your wallet.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateCPC() {
    if (_selectedAdType != null) {
      int price = _adPackages[_selectedAdType!]!['price'];
      int estimatedClicks = _adPackages[_selectedAdType!]!['estimatedClicks'];
      return price / estimatedClicks;
    }
    return 0.0;
  }

  double _calculateCPM() {
    if (_selectedAdType != null) {
      int price = _adPackages[_selectedAdType!]!['price'];
      int estimatedImpressions =
          _adPackages[_selectedAdType!]!['estimatedImpressions'] ?? 1;
      return (price / estimatedImpressions) * 1000;
    }
    return 0.0;
  }

  double _calculateFlatRate() {
    if (_selectedAdType != null) {
      return _adPackages[_selectedAdType!]!['flatRate']?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renew Ads'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_selectedPackage == null)
            Center(child: CircularProgressIndicator())
          else ...[
            // Display selected package info
            Text(
              'Selected Travel Package: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              _selectedPackage!.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // Ad Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAdType,
              decoration: InputDecoration(
                labelText: 'Ad Type',
                border: OutlineInputBorder(),
              ),
              items: _adPackages.keys
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAdType = value;
                  if (_startDate != null) {
                    _calculateEndDate();
                  }

                  _totalPrice = _adPackages[_selectedAdType!]!['price'];
                });
              },
            ),
            SizedBox(height: 30),

            Text('Renewal Type:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            RadioListTile<String>(
              title: Text('Automatic Renewal'),
              value: 'automatic',
              groupValue: _renewalType,
              onChanged: (value) {
                setState(() {
                  _renewalType = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Manual Renewal'),
              value: 'manual',
              groupValue: _renewalType,
              onChanged: (value) {
                setState(() {
                  _renewalType = value;
                });
              },
            ),

            SizedBox(height: 20),

            Text('Start and End Date:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            // Start Date Picker
            ElevatedButton(
              onPressed: () => _selectStartDate(context),
              child: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${DateFormat('dd MMM yyyy').format(_startDate!)}',
                  style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // End Date Display
            if (_endDate != null)
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0), // Adjust the padding as needed
                child: Text(
                  'End Date: ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            SizedBox(height: 20),

            // Submit Button
            SizedBox(height: 30),
            Spacer(),

            if (_selectedAdType != null) ...[
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'CPC: RM ${_calculateCPC().toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'CPM: RM ${_calculateCPM().toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Total Price: RM ${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            ElevatedButton(
              onPressed: _submitRenewalAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                padding: EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Renew Ad', style: TextStyle(color: Colors.white)),
            ),
          ],
        ]),
      ),
    );
  }
}
