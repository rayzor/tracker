Single Use Plastics Tracker App - by Coder Dojo Club (Glanmire)

A generic tracker App developed in Flutter (SDK by Google).
Dart is the coding language (by Google).

The App can be used to record Community use of Single Use Plastics.
It has 3 parts: SignIn/Login/Authentication + data entry + chart.

Based on Tommy's videos at https://learnflutterwithme.com/

- Database is Google Cloud Firestore.
- Collection is called 'entries'
- A document record is created for each user entry.
- The fields in the 'collection' document are locationID, logDate, quantity, userID, weekNumber, YearNumber.

- The charting feature aggregates community entries on a weekly basis and charts the overall progress of reducing single-use plastic usage. 
- It also provides insight into individual user trends by charting the User plastic usage. 
- The community locations are entered by the Club in Firestore database as Text.

ChatGPT assisted code was used in the coding of the App - amazing!.

===== Getting Started with Flutter by Google: Language is Dart.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.