import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../models/question_model.dart';
import '../models/answer_model.dart';

class QAService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  QAService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _questionsCol(String vehicleId) {
    return _db.collection('vehicles').doc(vehicleId).collection('questions');
  }

  CollectionReference<Map<String, dynamic>> _answersCol(
    String vehicleId,
    String questionId,
  ) {
    return _questionsCol(vehicleId).doc(questionId).collection('answers');
  }

  Future<void> askQuestion({
    required String vehicleId,
    required String sellerUserId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be authenticated to ask a question');
    }
    final buyerUserId = user.uid;
    final doc = _questionsCol(vehicleId).doc();
    final question = QuestionModel(
      id: doc.id,
      vehicleId: vehicleId,
      buyerUserId: buyerUserId,
      sellerUserId: sellerUserId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    try {
      developer.log('Storing question: ${question.toMap()}', name: 'QAService');
      await doc.set(question.toMap());
      developer.log(
        'Question stored successfully: ${doc.id}',
        name: 'QAService',
      );
    } catch (e) {
      developer.log('Error storing question: $e', name: 'QAService', error: e);
      rethrow;
    }
  }

  Stream<List<QuestionModel>> questionsForVehicle(String vehicleId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _questionsCol(vehicleId)
        .where('participants', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => QuestionModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> answerQuestion({
    required String vehicleId,
    required String questionId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be authenticated to answer');
    }
    final doc = _answersCol(vehicleId, questionId).doc();
    final answer = AnswerModel(
      id: doc.id,
      questionId: questionId,
      vehicleId: vehicleId,
      responderUserId: user.uid,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    try {
      developer.log('Storing answer: ${answer.toMap()}', name: 'QAService');
      await doc.set(answer.toMap());
      developer.log('Answer stored successfully: ${doc.id}', name: 'QAService');
      // increment answerCount
      await _questionsCol(
        vehicleId,
      ).doc(questionId).update({'answerCount': FieldValue.increment(1)});
      developer.log(
        'Updated answerCount for question: $questionId',
        name: 'QAService',
      );
    } catch (e) {
      developer.log('Error storing answer: $e', name: 'QAService', error: e);
      rethrow;
    }
  }

  Stream<List<AnswerModel>> answersForQuestion({
    required String vehicleId,
    required String questionId,
  }) {
    return _answersCol(vehicleId, questionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => AnswerModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
