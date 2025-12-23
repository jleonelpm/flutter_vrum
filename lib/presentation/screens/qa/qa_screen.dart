import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/qa_provider.dart';
import '../../../data/models/question_model.dart';
import '../../../providers/notification_provider.dart';

class QAScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String sellerUserId;
  const QAScreen({
    super.key,
    required this.vehicleId,
    required this.sellerUserId,
  });

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen> {
  final _questionCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debe iniciar sesión para usar Preguntas')),
      );
    }

    final questionsAsync = ref.watch(
      questionsForVehicleProvider(widget.vehicleId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionCtrl,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          final txt = _questionCtrl.text.trim();
                          if (txt.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La pregunta no puede estar vacía',
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            var sellerId = widget.sellerUserId;
                            if (sellerId.isEmpty) {
                              final snap = await FirebaseFirestore.instance
                                  .collection('vehicles')
                                  .doc(widget.vehicleId)
                                  .get();
                              final data = snap.data() as Map<String, dynamic>?;
                              sellerId = (data?['ownerId'] ?? '') as String;
                            }
                            await ref
                                .read(qaServiceProvider)
                                .askQuestion(
                                  vehicleId: widget.vehicleId,
                                  text: txt,
                                  sellerUserId: sellerId,
                                );
                            _questionCtrl.clear();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pregunta enviada'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        child: const Text('Preguntar'),
                      ),
              ],
            ),
          ),
          Expanded(
            child: questionsAsync.when(
              data: (questions) {
                if (questions.isEmpty) {
                  return const Center(child: Text('Sin preguntas todavía.'));
                }
                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return _QuestionThread(
                      vehicleId: widget.vehicleId,
                      question: q,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionThread extends ConsumerStatefulWidget {
  final String vehicleId;
  final QuestionModel question;
  const _QuestionThread({required this.vehicleId, required this.question});

  @override
  ConsumerState<_QuestionThread> createState() => _QuestionThreadState();
}

class _QuestionThreadState extends ConsumerState<_QuestionThread> {
  final _answerCtrl = TextEditingController();
  bool _isLoading = false;
  final Map<String, String> _nameCache = {};

  String _roleLabel(String uid) {
    final current = FirebaseAuth.instance.currentUser?.uid;
    if (uid == current) return 'Tú';
    if (uid == widget.question.sellerUserId) return 'Vendedor';
    if (uid == widget.question.buyerUserId) return 'Comprador';
    return 'Usuario';
  }

  Future<String> _displayName(String uid) async {
    if (_nameCache.containsKey(uid)) return _nameCache[uid]!;
    final fallback = _roleLabel(uid);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data();
      final raw =
          (data?['firstName'] ?? data?['name'] ?? data?['displayName'] ?? '')
              as String?;
      if (raw != null && raw.trim().isNotEmpty) {
        final first = raw.trim().split(RegExp(r'\s+')).first;
        _nameCache[uid] = first;
        return first;
      }
    } catch (_) {
      // Ignore and fallback
    }
    _nameCache[uid] = fallback;
    return fallback;
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answersAsync = ref.watch(
      answersForQuestionProvider((
        vehicleId: widget.vehicleId,
        questionId: widget.question.id,
      )),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _displayName(widget.question.buyerUserId),
              builder: (context, snap) {
                final name =
                    snap.data ?? _roleLabel(widget.question.buyerUserId);
                return Text(
                  '$name: ${widget.question.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            answersAsync.when(
              data: (answers) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (answers.isNotEmpty)
                      const Text(
                        'Respuestas:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    for (final a in answers)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: FutureBuilder<String>(
                          future: _displayName(a.responderUserId),
                          builder: (context, snap) {
                            final name =
                                snap.data ?? _roleLabel(a.responderUserId);
                            return Text('• $name: ${a.text}');
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerCtrl,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              hintText: 'Responder...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isLoading
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  final txt = _answerCtrl.text.trim();
                                  if (txt.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'La respuesta no puede estar vacía',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _isLoading = true);
                                  try {
                                    await ref
                                        .read(qaServiceProvider)
                                        .answerQuestion(
                                          vehicleId: widget.vehicleId,
                                          questionId: widget.question.id,
                                          text: txt,
                                        );
                                    // Seller answered: mark own notifications read for this vehicle
                                    await ref
                                        .read(notificationServiceProvider)
                                        .markReadForVehicle(widget.vehicleId);
                                    _answerCtrl.clear();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Respuesta enviada'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                },
                                child: const Text('Responder'),
                              ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
              error: (e, st) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('Error: $e'), const SizedBox(height: 8)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
