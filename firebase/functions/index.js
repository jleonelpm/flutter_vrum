const functions = require('firebase-functions');
const admin = require('firebase-admin');

try { admin.initializeApp(); } catch (e) {}

const db = admin.firestore();

exports.onQuestionCreate = functions.firestore
  .document('vehicles/{vehicleId}/questions/{questionId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const vehicleId = context.params.vehicleId;
    const questionId = context.params.questionId;

    const sellerUserId = data.sellerUserId;
    const buyerUserId = data.buyerUserId;

    // notify seller about the new question
    await db.collection('notifications').add({
      userId: sellerUserId,
      type: 'new_question',
      vehicleId,
      questionId,
      message: 'Nueva pregunta recibida',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
      fromUserId: buyerUserId,
    });
  });

exports.onAnswerCreate = functions.firestore
  .document('vehicles/{vehicleId}/questions/{questionId}/answers/{answerId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const vehicleId = context.params.vehicleId;
    const questionId = context.params.questionId;

    const responderUserId = data.responderUserId;

    // fetch question to get participants
    const qDoc = await db
      .collection('vehicles')
      .doc(vehicleId)
      .collection('questions')
      .doc(questionId)
      .get();

    if (!qDoc.exists) return;
    const q = qDoc.data();
    const sellerUserId = q.sellerUserId;
    const buyerUserId = q.buyerUserId;

    const targetUserId = responderUserId === sellerUserId ? buyerUserId : sellerUserId;
    const message = responderUserId === sellerUserId
      ? 'Respuesta del vendedor'
      : 'Respuesta del comprador';

    await db.collection('notifications').add({
      userId: targetUserId,
      type: 'new_answer',
      vehicleId,
      questionId,
      message,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
      fromUserId: responderUserId,
    });
  });
