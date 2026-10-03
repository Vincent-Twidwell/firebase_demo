import 'dart:async';                                     // new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart'; 




class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
    
  }
  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
// Add from here...
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;
  // ...to here.
  int _attendees = 0;
  int get attendees => _attendees;


int _attendingCount = 0;
int get attendingCount => _attendingCount;
StreamSubscription<DocumentSnapshot>? _attendingSubscription;
  Future<void> setAttendingCount(int count) {
  return FirebaseFirestore.instance
      .collection('attendees')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .set(<String, dynamic>{
    'attending': count > 0, // kept so your existing security rules still pass
    'count': count,
  });
}

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // Add from here...
    FirebaseFirestore.instance
    .collection('attendees')
    .snapshots()
    .listen((snapshot) {
  _attendees = snapshot.docs.fold<int>(0, (sum, doc) {
    final data = doc.data();
    final count = data['count'];
    if (count is int) return sum + count;
    // Older docs from the YES/NO version have no count: treat "true" as 1.
    return sum + (data['attending'] == true ? 1 : 0);
  });
  notifyListeners();
});
    // ...to here.

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        // Add from here...
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });
        // ...to here.
        // Add from here...
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          final data = snapshot.data();
          if (data == null) {
            _attendingCount = 0;
          } else if (data['count'] is int) {
            _attendingCount = data['count'] as int;
          } else {
            _attendingCount = data['attending'] == true ? 1 : 0;
          }
          notifyListeners();
        });
        // ...to here.
      } else {
        _loggedIn = false;
        // Add from here...
        _attendingCount = 0;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel(); // new

        // to here.
      }
      notifyListeners();
    });
    
  }
}