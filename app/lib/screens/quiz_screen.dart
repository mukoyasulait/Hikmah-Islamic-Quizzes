import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, int> _selectedAnswers = {};

  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  static const Color forest = Color(0xFF244638);
  static const Color deepGreen = Color(0xFF153C30);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);
  static const Color ink = Color(0xFF302D27);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await QuizService.getQuestions(
        categoryId: widget.categoryId,
        difficulty: widget.difficulty,
        limit: 20,
      );

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _isLoading = false;

        if (questions.isEmpty) {
          _error = 'No questions are available for this level yet.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int optionId) {
    if (_isSubmitting) return;

    setState(() {
      _selectedAnswers[_questions[_currentIndex]['id'] as int] =
          optionId;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_selectedAnswers.length != _questions.length) {
      final unanswered = _questions.length - _selectedAnswers.length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions. $unanswered remaining.'),
          backgroundColor: forest,
        ),
      );
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: paper,
        title: const Text('Submit Quiz?'),
        content: const Text(
          'Are you sure you want to submit your answers? '
          'You cannot change them afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true || !mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = _questions.map((question) {
        final questionId = question['id'] as int;

        return {
          'question_id': questionId,
          'selected_option_id': _selectedAnswers[questionId]!,
        };
      }).toList();

      final result = await QuizService.submitQuiz(
        categoryId: widget.categoryId,
        difficulty: widget.difficulty,
        answers: answers,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            result: result,
            categoryName: widget.categoryName,
            difficulty: widget.difficulty,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hikmah Quiz',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: forest),
            )
          : _error != null
              ? _buildError()
              : _buildQuiz(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 55,
              color: forest,
            ),
            const SizedBox(height: 18),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ink,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: forest),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentIndex];
    final questionId = question['id'] as int;
    final options = question['options'] as List<dynamic>;
    final selectedOptionId = _selectedAnswers[questionId];

    final progress = (_currentIndex + 1) / _questions.length;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.difficulty,
                        style: const TextStyle(
                          color: forest,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Question ${_currentIndex + 1} of ${_questions.length}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white,
                      color: gold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUESTION',
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          question['question_text']?.toString() ?? '',
                          style: const TextStyle(
                            color: ink,
                            fontSize: 20,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'SELECT YOUR ANSWER',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 13),
                  ...List.generate(options.length, (index) {
                    final option = Map<String, dynamic>.from(options[index]);
                    final optionId = option['id'] as int;
                    final isSelected = selectedOptionId == optionId;
                    final letters = ['A', 'B', 'C', 'D'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(optionId),
                        borderRadius: BorderRadius.circular(13),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? forest : paper,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: isSelected ? forest : Colors.black12,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.16)
                                      : cream,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  index < letters.length
                                      ? letters[index]
                                      : '${index + 1}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : forest,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  option['option_text']?.toString() ?? '',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : ink,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final isLastQuestion = _currentIndex == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        color: paper,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentIndex == 0 || _isSubmitting
                  ? null
                  : _previousQuestion,
              style: OutlinedButton.styleFrom(
                foregroundColor: forest,
                side: const BorderSide(color: forest),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : isLastQuestion
                      ? _submitQuiz
                      : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
