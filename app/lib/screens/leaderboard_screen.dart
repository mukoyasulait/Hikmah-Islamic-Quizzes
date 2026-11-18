
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/category_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const Color forest = Color(0xFF244638);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);
  static const Color ink = Color(0xFF302D27);

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> leaderboard = [];

  int? selectedCategoryId;
  bool isLoadingCategories = true;
  bool isLoadingLeaderboard = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await CategoryService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        isLoadingCategories = false;
      });

      if (categories.isNotEmpty) {
        final firstId = int.tryParse(
          categories.first['id'].toString(),
        );

        if (firstId != null) {
          await _loadLeaderboard(firstId);
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingCategories = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadLeaderboard(int categoryId) async {
    setState(() {
      selectedCategoryId = categoryId;
      isLoadingLeaderboard = true;
      errorMessage = null;
      leaderboard = [];
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please sign in to view the leaderboard.');
      }

      final uri = Uri.parse(
        '${AuthService.baseUrl}/leaderboard/',
      ).replace(
        queryParameters: {
          'category_id': categoryId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          leaderboard = data
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
          isLoadingLeaderboard = false;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Your session has expired. Please sign in again.');
      } else if (response.statusCode == 404) {
        throw Exception('The selected category could not be found.');
      } else {
        throw Exception('Could not load the leaderboard. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingLeaderboard = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshLeaderboard() async {
    if (selectedCategoryId != null) {
      await _loadLeaderboard(selectedCategoryId!);
    }
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD5A52F);
      case 2:
        return const Color(0xFF9A9A9A);
      case 3:
        return const Color(0xFFB8794D);
      default:
        return forest;
    }
  }

  IconData _rankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.workspace_premium_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _selectedCategoryName() {
    for (final category in categories) {
      if (int.tryParse(category['id'].toString()) ==
          selectedCategoryId) {
        return category['name']?.toString() ?? 'Category';
      }
    }

    return 'Leaderboard';
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
          'Leaderboard',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: selectedCategoryId == null || isLoadingLeaderboard
                ? null
                : _refreshLeaderboard,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh rankings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoadingCategories
          ? const Center(
              child: CircularProgressIndicator(color: forest),
            )
          : categories.isEmpty
              ? _buildErrorState(
                  errorMessage ?? 'No categories are available.',
                  _loadCategories,
                )
              : RefreshIndicator(
                  color: forest,
                  onRefresh: _refreshLeaderboard,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                    children: [
                      const Text(
                        'A journey of knowledge',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: forest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'See how learners are performing this week. '
                        'Choose a category to explore the rankings.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),

                      _buildCategorySelector(),

                      const SizedBox(height: 22),

                      _buildWeeklyBanner(),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'WEEKLY RANKINGS',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Text(
                            '${leaderboard.length} learners',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (isLoadingLeaderboard)
                        const Padding(
                          padding: EdgeInsets.all(45),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: forest,
                            ),
                          ),
                        )
                      else if (errorMessage != null)
                        _buildErrorState(
                          errorMessage!,
                          () => _loadLeaderboard(selectedCategoryId!),
                        )
                      else if (leaderboard.isEmpty)
                        _buildEmptyState()
                      else ...[
                        if (leaderboard.isNotEmpty)
                          _buildTopThree(),

                        const SizedBox(height: 16),

                        ...leaderboard
                            .where(
                              (entry) =>
                                  (entry['rank'] as num).toInt() > 3,
                            )
                            .map(_buildRankingTile),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9E0D2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedCategoryId,
          isExpanded: true,
          hint: const Text('Select a category'),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: forest,
          ),
          dropdownColor: paper,
          style: const TextStyle(
            color: forest,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: categories.map((category) {
            final id = int.tryParse(category['id'].toString());

            return DropdownMenuItem<int>(
              value: id,
              child: Text(category['name']?.toString() ?? 'Category'),
            );
          }).where((item) => item.value != null).toList(),
          onChanged: (value) {
            if (value != null) {
              _loadLeaderboard(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: gold,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This week\'s challenge',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _selectedCategoryName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Learn, improve and rise through the ranks.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    final topThree = leaderboard
        .where(
          (entry) => (entry['rank'] as num).toInt() <= 3,
        )
        .toList();

    return Column(
      children: [
        if (topThree.isNotEmpty)
          _buildRankingTile(topThree[0], featured: true),
        if (topThree.length > 1)
          _buildRankingTile(topThree[1]),
        if (topThree.length > 2)
          _buildRankingTile(topThree[2]),
      ],
    );
  }

  Widget _buildRankingTile(
    Map<String, dynamic> entry, {
    bool featured = false,
  }) {
    final rank = (entry['rank'] as num).toInt();
    final username = entry['username']?.toString() ?? 'Learner';
    final percentage = double.tryParse(
          entry['score_percentage'].toString(),
        ) ??
        0;

    final rankColor = _rankColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(featured ? 19 : 15),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: featured
              ? gold.withValues(alpha: 0.65)
              : const Color(0xFFE9E0D2),
          width: featured ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      _rankIcon(rank),
                      color: rankColor,
                      size: 23,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: ink,
                    fontSize: featured ? 17 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rank == 1
                      ? 'Top learner'
                      : rank == 2
                          ? 'Second place'
                          : rank == 3
                              ? 'Third place'
                              : 'Rank #$rank',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: rankColor,
              fontSize: featured ? 20 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E0D2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: gold,
            size: 48,
          ),
          SizedBox(height: 14),
          Text(
            'No rankings yet',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: forest,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are no completed learner quizzes in this category '
            'for the current week. Be the first to take the challenge!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    VoidCallback onRetry,
  ) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 45,
            color: muted,
          ),
          const SizedBox(height: 15),
          const Text(
            'Unable to load rankings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: forest,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
