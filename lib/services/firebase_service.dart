

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/note_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled by the user.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');

  Stream<List<NoteModel>> getNotesStream(String userId) {
    return _notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }

  Future<void> createNote({
    required String title,
    required String content,
    required String userId,
  }) async {
    final note = NoteModel(
      id: '',
      title: title,
      content: content,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _notesCollection.add(note.toMap());
  }

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

  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}
