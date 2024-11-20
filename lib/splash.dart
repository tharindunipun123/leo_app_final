import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'StartScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade controller
    _fadeController = AnimationController(
      vsync: this,
      duration:  const Duration(seconds: 2),
    );

    // Initialize scale controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    ));

    // Create scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Start animations sequence
    _startAnimationSequence();

    // Check shared preferences after animations
    Future.delayed(const Duration(seconds: 3), () {
      checkUserData();
    });
  }

  void _startAnimationSequence() async {
    // Start fade in and scale up
    await Future.wait([
      _fadeController.forward(),
      _scaleController.forward(),
    ]);

    // Wait for a moment
    await Future.delayed(const Duration(seconds: 1));

    // Fade out
    await _fadeController.reverse();
  }

  Future<void> checkUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? userId = prefs.getString('userId');
    final String? firstname = prefs.getString('firstName');

    if (!mounted) return;

    if (userId != null && firstname != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userId: userId,
            username: firstname,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StartScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/logo.png', // Add your logo image here
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // App Name with custom font
                        Text(
                          'Your App Name',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Loading Indicator
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Copyright text at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Powered by',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leo House Technologies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}