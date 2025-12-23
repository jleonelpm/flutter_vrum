import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/qa_service.dart';
import '../data/models/question_model.dart';
import '../data/models/answer_model.dart';

final qaServiceProvider = Provider<QAService>((ref) => QAService());

final questionsForVehicleProvider =
    StreamProvider.family<List<QuestionModel>, String>((ref, vehicleId) {
      final service = ref.watch(qaServiceProvider);
      return service.questionsForVehicle(vehicleId);
    });

final answersForQuestionProvider =
    StreamProvider.family<
      List<AnswerModel>,
      ({String vehicleId, String questionId})
    >((ref, q) {
      final service = ref.watch(qaServiceProvider);
      return service.answersForQuestion(
        vehicleId: q.vehicleId,
        questionId: q.questionId,
      );
    });

final askQuestionProvider =
    FutureProvider.family<
      void,
      ({String vehicleId, String sellerUserId, String text})
    >((ref, args) async {
      final service = ref.read(qaServiceProvider);
      return service.askQuestion(
        vehicleId: args.vehicleId,
        sellerUserId: args.sellerUserId,
        text: args.text,
      );
    });

final answerQuestionProvider =
    FutureProvider.family<
      void,
      ({String vehicleId, String questionId, String text})
    >((ref, args) async {
      final service = ref.read(qaServiceProvider);
      return service.answerQuestion(
        vehicleId: args.vehicleId,
        questionId: args.questionId,
        text: args.text,
      );
    });
