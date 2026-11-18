
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String categoryName;
  final String difficulty;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.categoryName,
    required this.difficulty,
  });

  static const Color forest = Color(0xFF244638);
  static const Color deepGreen = Color(0xFF153C30);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);
  static const Color ink = Color(0xFF302D27);

  @override
  Widget build(BuildContext context) {
    final int score = (result['score'] as num?)?.toInt() ?? 0;
    final int total = (result['total_questions'] as num?)?.toInt() ?? 0;
    final double percentage =
        (result['percentage'] as num?)?.toDouble() ?? 0;

    final List<dynamic> answers =
        result['results'] as List<dynamic>? ?? [];

    final bool passed = percentage >= 50;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Quiz Results',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Icon(
                      passed
                          ? Icons.emoji_events_outlined
                          : Icons.menu_book_outlined,
                      size: 65,
                      color: gold,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      passed ? 'Well Done!' : 'Keep Learning!',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: forest,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '$categoryName • $difficulty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Score card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: deepGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'YOUR FINAL SCORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$score out of $total correct',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              minHeight: 9,
                              backgroundColor: Colors.white24,
                              color: gold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Performance summary
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Correct',
                            '$score',
                            Icons.check_circle_outline,
                            forest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Incorrect',
                            '${total - score}',
                            Icons.cancel_outlined,
                            Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Total',
                            '$total',
                            Icons.quiz_outlined,
                            gold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ANSWER REVIEW',
                        style: TextStyle(
                          color: forest,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    ...List.generate(answers.length, (index) {
                      final answer =
                          Map<String, dynamic>.from(answers[index]);

                      return _answerCard(answer, index + 1);
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: paper,
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerCard(Map<String, dynamic> answer, int number) {
    final bool isCorrect = answer['is_correct'] == true;

    final String question =
        answer['question_text']?.toString() ?? 'Question unavailable';

    final String explanation =
        answer['explanation']?.toString() ?? 'No explanation provided.';

    final String? sourceReference =
        answer['source_reference']?.toString();

    final int? correctOptionId =
        (answer['correct_option_id'] as num?)?.toInt();

    final int? selectedOptionId =
        (answer['selected_option_id'] as num?)?.toInt();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCorrect
              ? forest.withValues(alpha: 0.25)
              : Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'QUESTION $number',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? forest : Colors.red.shade700,
                size: 19,
              ),
              const SizedBox(width: 5),
              Text(
                isCorrect ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  color: isCorrect ? forest : Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              'Correct option ID: ${correctOptionId ?? 'Unavailable'}',
              style: const TextStyle(
                color: forest,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your selected option ID: ${selectedOptionId ?? 'Unavailable'}',
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXPLANATION',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  explanation,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (sourceReference != null &&
                    sourceReference.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'SOURCE REFERENCE',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sourceReference,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
