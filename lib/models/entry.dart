// Model Entry - ChatGPT code
// A model class for a Firebase Firestore database with a collection named "entries"
//This model class has a constructor that takes in the required fields as arguments,
// as well as a factory constructor fromSnapshot
// that converts a Firebase DocumentSnapshot to an Entry object.
// The toMap method is used to convert an Entry object to a Map<String, dynamic>
// that can be stored in the database.

import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String locationID;
  final DateTime logDate;
  final int quantity;
  final String userID;
  final int weekNumber;
  final int yearNumber;

  // A constructor that takes in the required fields as arguments
  Entry({
    required this.locationID,
    required this.logDate,
    required this.quantity,
    required this.userID,
    required this.weekNumber,
    required this.yearNumber,
  });

  // A factory constructor fromSnapshot that converts
  // a Firebase DocumentSnapshot to an Entry object.
  factory Entry.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return Entry(
      locationID: data['locationID'],
      logDate: (data['logDate'] as Timestamp).toDate(),
      quantity: data['quantity'],
      userID: data['userID'],
      weekNumber: data['weekNumber'],
      yearNumber: data['yearNumber'],
    );
  }

  // The toMap method is used to convert an Entry object
  // to a Map<String, dynamic> that can be stored in the database.
  Map<String, dynamic> toMap() {
    return {
      'locationID': locationID,
      'logDate': logDate,
      'quantity': quantity,
      'userID': userID,
      'weekNumber': weekNumber,
      'yearNumber': yearNumber,
    };
  }
}
