import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/category_service.dart';
import 'screens/difficulty_selection_screen.dart';
import 'screens/quiz_history_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const HikmahApp());
}

class HikmahApp extends StatelessWidget {
  const HikmahApp({super.key});

  static const Color forest = Color(0xFF244638);
  static const Color deepGreen = Color(0xFF153C30);
  static const Color cream = Color(0xFFF8F1E6);
  static const Color paper = Color(0xFFFFFCF6);
  static const Color gold = Color(0xFFC19A52);
  static const Color muted = Color(0xFF82796D);
  static const Color ink = Color(0xFF302D27);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hikmah Islamic Quizzes',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          primary: forest,
          secondary: gold,
          surface: paper,
        ),
        fontFamily: 'serif',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --------------------------------------------------
// WELCOME SCREEN
// --------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27),
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.nightlight_round,
                color: HikmahApp.gold,
                size: 35,
              ),

              const SizedBox(height: 12),

              const Icon(
                Icons.menu_book_rounded,
                size: 65,
                color: HikmahApp.forest,
              ),

              const SizedBox(height: 18),

              const Text(
                'HIKMAH',
                style: TextStyle(
                  fontSize: 43,
                  fontWeight: FontWeight.w600,
                  color: HikmahApp.deepGreen,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'ISLAMIC QUIZZES',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: HikmahApp.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Knowledge is a journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: HikmahApp.deepGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Explore Islamic knowledge, challenge your '
                'understanding and discover how much you know.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: HikmahApp.muted,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HikmahApp.forest,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HikmahApp.deepGreen,
                    side: const BorderSide(color: HikmahApp.gold),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 17)),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'LEARN  ·  REFLECT  ·  EXCEL',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: HikmahApp.muted,
                ),
              ),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// REUSABLE INPUT FIELD
// --------------------------------------------------

Widget hikmahField({
  required String label,
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  bool password = false,
  bool obscure = false,
  VoidCallback? togglePassword,
  TextInputType keyboard = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: HikmahApp.deepGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 9),
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: password && obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: HikmahApp.muted, fontSize: 14),
          prefixIcon: Icon(icon, color: HikmahApp.gold, size: 21),
          suffixIcon: password
              ? IconButton(
                  onPressed: togglePassword,
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: HikmahApp.muted,
                  ),
                )
              : null,
          filled: true,
          fillColor: HikmahApp.paper,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFE9DFCE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: HikmahApp.forest, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    ],
  );
}

// --------------------------------------------------
// REGISTRATION SCREEN
// --------------------------------------------------

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HikmahApp.cream,
        foregroundColor: HikmahApp.deepGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 12, 25, 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Begin your journey',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    color: HikmahApp.deepGreen,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'Create an account to explore Islamic knowledge.',
                  style: TextStyle(
                    color: HikmahApp.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 29),

                hikmahField(
                  label: 'Username',
                  hint: 'Choose a username',
                  icon: Icons.person_outline,
                  controller: username,
                  validator: (v) {
                    if (v == null || v.trim().length < 3) {
                      return 'Enter at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                hikmahField(
                  label: 'Email address',
                  hint: 'example@email.com',
                  icon: Icons.email_outlined,
                  controller: email,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                hikmahField(
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  controller: password,
                  password: true,
                  obscure: hidePassword,
                  togglePassword: () {
                    setState(() => hidePassword = !hidePassword);
                  },
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                hikmahField(
                  label: 'Confirm password',
                  hint: 'Enter your password again',
                  icon: Icons.lock_outline,
                  controller: confirmPassword,
                  password: true,
                  obscure: hideConfirm,
                  togglePassword: () {
                    setState(() => hideConfirm = !hideConfirm);
                  },
                  validator: (v) {
                    if (v != password.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            setState(() => isLoading = true);

                            try {
                              await AuthService.register(
                                username: username.text.trim(),
                                email: email.text.trim(),
                                password: password.text,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Account created successfully! Please sign in.',
                                  ),
                                  backgroundColor: HikmahApp.forest,
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HikmahApp.forest,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 19),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(color: HikmahApp.forest),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// LOGIN SCREEN
// --------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HikmahApp.cream,
        foregroundColor: HikmahApp.deepGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 62,
                    color: HikmahApp.forest,
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: HikmahApp.deepGreen,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'Continue your journey of Islamic knowledge.',
                  style: TextStyle(color: HikmahApp.muted, fontSize: 14),
                ),

                const SizedBox(height: 36),

                hikmahField(
                  label: 'Email address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: email,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 23),

                hikmahField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  controller: password,
                  password: true,
                  obscure: hidePassword,
                  togglePassword: () {
                    setState(() => hidePassword = !hidePassword);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: HikmahApp.forest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            setState(() => isLoading = true);

                            try {
                              final loginResponse = await AuthService.login(
                                email: email.text.trim(),
                                password: password.text,
                              );

                              final accessToken =
                                  loginResponse['access_token'] as String;

                              final currentUser =
                                  await AuthService.getCurrentUser(accessToken);

                              if (!context.mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DashboardScreen(user: currentUser),
                                ),
                                (route) => false,
                              );
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HikmahApp.forest,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: 22),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: HikmahApp.forest),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// FORGOT PASSWORD SCREEN
// --------------------------------------------------

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HikmahApp.cream,
        foregroundColor: HikmahApp.deepGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_reset_rounded,
                  size: 58,
                  color: HikmahApp.forest,
                ),

                const SizedBox(height: 25),

                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    color: HikmahApp.deepGreen,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Enter your registered email address to begin '
                  'recovering access to your account.',
                  style: TextStyle(
                    color: HikmahApp.muted,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                hikmahField(
                  label: 'Email address',
                  hint: 'Enter your registered email',
                  icon: Icons.email_outlined,
                  controller: email,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password recovery connection comes next.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HikmahApp.forest,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// LEARNER DASHBOARD
// --------------------------------------------------

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = CategoryService.getCategories();
  }

  IconData _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'ulum al-quran':
        return Icons.menu_book_rounded;
      case 'hadith studies':
        return Icons.auto_stories_rounded;
      case 'fiqh':
        return Icons.balance_rounded;
      case 'aqeedah':
        return Icons.lightbulb_outline_rounded;
      case 'islamic history':
        return Icons.history_edu_rounded;
      case 'akhlaq':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.school_outlined;
    }
  }

  void _reloadCategories() {
    setState(() {
      categoriesFuture = CategoryService.getCategories();
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
Widget build(BuildContext context) {
  final pages = [
    _homePage(),
    const QuizHistoryScreen(),
    const LeaderboardScreen(),
    ProfileScreen(
      user: widget.user,
      onLogout: _logout,
    ),
  ];

    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: HikmahApp.paper,
        indicatorColor: const Color(0xFFE5E9DF),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            label: 'Quizzes',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFFE6DDCB),
                child: Icon(Icons.person, color: HikmahApp.forest),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamu Alaikum',
                      style: TextStyle(
                        fontSize: 21,
                        color: HikmahApp.deepGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Welcome, ${widget.user?['username'] ?? 'to Hikmah'}',
                      style: TextStyle(fontSize: 12, color: HikmahApp.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: HikmahApp.forest,
                  size: 27,
                ),
              ),
            ],
          ),

          const SizedBox(height: 27),

          const Text(
            'A little knowledge, every day.',
            style: TextStyle(
              fontSize: 23,
              color: HikmahApp.deepGreen,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: HikmahApp.forest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY\'S CHALLENGE',
                  style: TextStyle(
                    color: Color(0xFFE8D4A7),
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'How well do you know the Quran?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Take a few minutes to test your knowledge.',
                  style: TextStyle(
                    color: Color(0xFFE1E7DF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() => selectedIndex = 1);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: HikmahApp.cream,
                      foregroundColor: HikmahApp.deepGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 21,
                        vertical: 11,
                      ),
                    ),
                    child: const Text('Explore quizzes'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore Categories',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: HikmahApp.deepGreen,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => selectedIndex = 1);
                },
                child: const Text(
                  'View all',
                  style: TextStyle(color: HikmahApp.gold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: CircularProgressIndicator(color: HikmahApp.forest),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: HikmahApp.paper,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE9DFCE)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: HikmahApp.muted,
                        size: 30,
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Could not load categories',
                        style: TextStyle(
                          color: HikmahApp.deepGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HikmahApp.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _reloadCategories,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: HikmahApp.paper,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE9DFCE)),
                  ),
                  child: const Text(
                    'No categories are available yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HikmahApp.muted),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final name = category['name']?.toString() ?? 'Category';
                  final description = category['description']?.toString() ?? '';

                  return InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      final categoryId = int.tryParse(
                        category['id'].toString(),
                      );

                      if (categoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid category ID.')),
                        );
                        return;
                      }

                      final selectedDifficulty = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DifficultySelectionScreen(
                            categoryId: categoryId,
                            categoryName: name,
                          ),
                        ),
                      );

                      if (!context.mounted || selectedDifficulty == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$name - $selectedDifficulty selected.',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: HikmahApp.paper,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFE9DFCE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _categoryIcon(name),
                            color: HikmahApp.gold,
                            size: 27,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: HikmahApp.deepGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              color: HikmahApp.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: HikmahApp.deepGreen,
            ),
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HikmahApp.paper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE9DFCE)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _ProgressItem(value: '0', label: 'Quizzes taken'),
                ),
                Expanded(
                  child: _ProgressItem(value: '0%', label: 'Average score'),
                ),
                Expanded(
                  child: _ProgressItem(value: '0', label: 'Completed'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}

class _ProgressItem extends StatelessWidget {
  final String value;
  final String label;

  const _ProgressItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: HikmahApp.forest,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: HikmahApp.muted),
        ),
      ],
    );
  }
}
