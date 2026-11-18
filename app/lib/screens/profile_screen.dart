import 'package:flutter/material.dart';

import '../services/quiz_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color forest = Color(0xFF244638);
  static const Color deepGreen = Color(0xFF153C30);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);
  static const Color ink = Color(0xFF302D27);

  late Future<List<Map<String, dynamic>>> historyFuture;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    historyFuture = QuizService.getQuizHistory();
  }

  String _userValue(List<String> keys, {String fallback = 'Not provided'}) {
    for (final key in keys) {
      final value = widget.user?[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return fallback;
  }

  String get username => _userValue(
        ['username', 'name', 'full_name'],
        fallback: 'Learner',
      );

  String get email => _userValue(['email']);

  Future<void> _refreshHistory() async {
    setState(() {
      historyFuture = QuizService.getQuizHistory();
    });
    await historyFuture;
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: paper,
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of Hikmah Islamic Quizzes?',
          style: TextStyle(color: muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: forest)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => isLoggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) {
        setState(() => isLoggingOut = false);
      }
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: deepGreen,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9DFCE)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: forest, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE9DFCE)),
        ),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 22),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                color: forest,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(List<Map<String, dynamic>> history) {
    final completed = history.where((attempt) {
      final status = attempt['status']?.toString().toLowerCase();
      return status == null || status == 'completed';
    }).toList();

    final percentages = completed
        .map((attempt) => double.tryParse(
              (attempt['percentage'] ?? 0).toString(),
            ) ?? 0)
        .toList();

    final average = percentages.isEmpty
        ? 0.0
        : percentages.reduce((a, b) => a + b) / percentages.length;

    return Row(
      children: [
        _statCard('${completed.length}', 'Quizzes taken', Icons.quiz_outlined),
        const SizedBox(width: 10),
        _statCard('${average.toStringAsFixed(1)}%', 'Average score',
            Icons.trending_up_rounded),
        const SizedBox(width: 10),
        _statCard('${completed.length}', 'Completed',
            Icons.check_circle_outline_rounded),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'L';

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshHistory,
            tooltip: 'Refresh profile statistics',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        color: forest,
        onRefresh: _refreshHistory,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 18),
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 39,
                    backgroundColor: const Color(0xFFE8D4A7),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 31,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE1E7DF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hikmah Learner',
                      style: TextStyle(color: Color(0xFFE8D4A7), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _sectionTitle('Your learning progress'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(25),
                    child: Center(
                      child: CircularProgressIndicator(color: forest),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9DFCE)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Could not load quiz statistics.',
                          style: TextStyle(color: muted),
                        ),
                        TextButton(
                          onPressed: _refreshHistory,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }

                return _buildStatistics(snapshot.data ?? []);
              },
            ),
            const SizedBox(height: 26),
            _sectionTitle('Account information'),
            _infoTile(
              icon: Icons.person_outline_rounded,
              label: 'Username',
              value: username,
            ),
            _infoTile(
              icon: Icons.email_outlined,
              label: 'Email address',
              value: email,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 53,
              child: OutlinedButton.icon(
                onPressed: isLoggingOut ? null : _confirmLogout,
                icon: isLoggingOut
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(isLoggingOut ? 'Signing out...' : 'Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
