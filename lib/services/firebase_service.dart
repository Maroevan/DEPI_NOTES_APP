

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/note_model.dart';

class FirebaseService {
  // Singleton pattern so only one instance is created
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // AUTH: current user getter


  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  // AUTH: Google Sign-In


  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google account picker
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled by the user.');
    }

    // Obtain auth details from the Google account
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new Firebase credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }


  // AUTH: Sign Out


  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }


  // FIRESTORE: Notes collection reference


  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');


  // FIRESTORE: Fetch notes (real-time stream)


  Stream<List<NoteModel>> getNotesStream(String userId) {
    return _notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }


  // FIRESTORE: Create a new note


  Future<void> createNote({
    required String title,
    required String content,
    required String userId,
  }) async {
    final note = NoteModel(
      id: '', // Firestore will auto-generate the ID
      title: title,
      content: content,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _notesCollection.add(note.toMap());
  }


  // FIRESTORE: Update an existing note


  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    await _notesCollection.doc(noteId).update({
      'title': title,
      'content': content,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }


  // FIRESTORE: Delete a note


  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}
