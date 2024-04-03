import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> returnFirebaseInfo(String field) async {
  try {
    // Initialize Firebase app if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBT3jXJSI9faDzoBY0cZ-aXOdS7ZcXUDaU',
          appId: '1:969628663426:android:bf800db728b868642dbe9b',
          messagingSenderId: '969628663426',
          projectId: 'ibm-database-2',
        ),
      );
    }

    // Access Firestore instance
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Retrieve data from Firestore
    DocumentSnapshot snapshot =
    await _firestore.collection('Work').doc(field).get();
    String extractedText = snapshot.get("Description");
    return extractedText;
  } catch (e) {
    print('Error occurred: $e');
    return null;
  }
}
