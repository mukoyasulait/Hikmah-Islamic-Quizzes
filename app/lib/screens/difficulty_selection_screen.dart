
import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const DifficultySelectionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  static const Color forest = Color(0xFF244638);
  static const Color deepGreen = Color(0xFF153C30);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);

  final List<Map<String, dynamic>> levels = const [
    {
      'name': 'Beginner',
      'description': 'Build your foundation and learn the essentials.',
      'icon': Icons.spa_rounded,
      'questions': '20 Questions',
    },
    {
      'name': 'Intermediate',
      'description': 'Strengthen your knowledge and understanding.',
      'icon': Icons.menu_book_rounded,
      'questions': '20 Questions',
    },
    {
      'name': 'Advanced',
      'description': 'Challenge yourself with deeper questions.',
      'icon': Icons.workspace_premium_rounded,
      'questions': '20 Questions',
    },
  ];

  void _openQuiz(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          difficulty: difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: deepGreen,
        elevation: 0,
        title: const Text('Choose Difficulty'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 43,
                color: gold,
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Your Level',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  color: deepGreen,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'You selected $categoryName. '
                'Choose a difficulty level to continue.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: muted,
                ),
              ),
              const SizedBox(height: 28),

              ...levels.map((level) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: () {
                      _openQuiz(
                        context,
                        level['name'] as String,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: paper,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE9DFCE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              level['icon'] as IconData,
                              color: gold,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: deepGreen,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  level['description'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: muted,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  level['questions'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: forest,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                            color: gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: forest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFE8D4A7),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose the level that best matches '
                        'your current knowledge.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
