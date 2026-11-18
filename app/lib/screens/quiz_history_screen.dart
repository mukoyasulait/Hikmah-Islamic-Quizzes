
import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/category_service.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  static const Color forest = Color(0xFF244638);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);

  late Future<_HistoryData> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<_HistoryData> _loadHistory() async {
    final history = await QuizService.getQuizHistory();

    final Map<int, String> categoryNames = {};

    try {
      final categories = await CategoryService.getCategories();

      for (final category in categories) {
        final id = category['id'];
        final name = category['name'];

        if (id != null && name != null) {
          categoryNames[int.parse(id.toString())] = name.toString();
        }
      }
    } catch (_) {
      // History can still be displayed if category names fail to load.
    }

    return _HistoryData(
      attempts: history,
      categoryNames: categoryNames,
    );
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyFuture = _loadHistory();
    });

    await _historyFuture;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date unavailable';

    final date = DateTime.tryParse(dateValue.toString());

    if (date == null) return 'Date unavailable';

    final localDate = date.toLocal();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final day = localDate.day.toString().padLeft(2, '0');

    return '$day ${months[localDate.month - 1]} ${localDate.year}';
  }

  Color _scoreColor(double percentage) {
    if (percentage >= 70) return forest;
    if (percentage >= 50) return gold;
    return const Color(0xFFB65C4B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'My Quizzes',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder<_HistoryData>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: forest),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final data = snapshot.data;
          final attempts = data?.attempts ?? [];

          if (attempts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: forest,
            onRefresh: _refreshHistory,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                const Text(
                  'Your learning journey',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: forest,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review your completed quizzes and track your progress.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),

                _buildSummaryCard(attempts),

                const SizedBox(height: 28),

                const Text(
                  'QUIZ HISTORY',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                ...attempts.map((attempt) {
                  return _buildAttemptCard(
                    attempt,
                    data!.categoryNames,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> attempts) {
    final totalAttempts = attempts.length;

    final average = attempts.fold<double>(
          0,
          (sum, attempt) =>
              sum + (double.tryParse(
                attempt['percentage'].toString(),
              ) ?? 0),
        ) /
        totalAttempts;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your overall progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${average.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Average quiz score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalAttempts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Completed',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptCard(
    Map<String, dynamic> attempt,
    Map<int, String> categoryNames,
  ) {
    final categoryId = int.tryParse(
      attempt['category_id'].toString(),
    );

    final categoryName = categoryNames[categoryId] ??
        'Category ${attempt['category_id']}';

    final score = attempt['score'] ?? 0;
    final total = attempt['total_questions'] ?? 0;

    final percentage = double.tryParse(
          attempt['percentage'].toString(),
        ) ??
        0;

    final date = _formatDate(attempt['completed_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9E0D2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _scoreColor(percentage),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: muted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '$score / $total correct',
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_outlined,
                color: muted,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: cream,
              color: _scoreColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: const BoxDecoration(
                color: Color(0xFFECE4D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: forest,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No quizzes yet',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your completed quizzes will appear here. '
              'Start a quiz to begin tracking your learning journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 50,
              color: muted,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load quiz history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _historyFuture = _loadHistory();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryData {
  final List<Map<String, dynamic>> attempts;
  final Map<int, String> categoryNames;

  _HistoryData({
    required this.attempts,
    required this.categoryNames,
  });
}
