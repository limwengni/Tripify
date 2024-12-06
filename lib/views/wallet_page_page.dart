import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double? walletAmount = 0; // Initial wallet amount
  FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  UserModel? user;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              walletAmount!=null?
              'RM ${walletAmount!.toStringAsFixed(2)}':'RM 0' ,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor:          const Color.fromARGB(255, 159, 118, 249),

                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 50,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Cash Out', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
    
    );
  }
}
