import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> returnFirebaseInfo(String field) async {

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBT3jXJSI9faDzoBY0cZ-aXOdS7ZcXUDaU',
      appId: '1:969628663426:android:bf800db728b868642dbe9b',
      messagingSenderId: '969628663426',
      projectId: 'ibm-database-2',
    ),
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  WidgetsFlutterBinding.ensureInitialized();

  try {
    DocumentSnapshot snapshot = await _firestore.collection('Work').doc('WbH7pc5HCBscTHGVfWMe').get();
    String extractedText = snapshot.get(field);
    return extractedText;
  } catch (e) {
    print('Error occurred: $e');
    return null;
  }
}
