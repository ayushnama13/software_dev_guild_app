import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

class CombinedAuthPage extends StatefulWidget {
  const CombinedAuthPage({super.key});

  @override
  State<CombinedAuthPage> createState() => _CombinedAuthPageState();
}

class _CombinedAuthPageState extends State<CombinedAuthPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final endpoint = _isLogin ? '/login' : '/signup';
      final response = await http.post(
        Uri.parse('http://13.60.167.160:8000$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Save the User ID to our static session variable!
        DatabaseService.currentUserId = data['user']['id'];
        await DatabaseService.saveSession(data['user']['id'], data['user']['email']);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Show FastAPI error message
        throw Exception(data['detail'] ?? 'Authentication failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    const Hero(
                      tag: 'nova_logo',
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.blueAccent,
                        size: 80,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated Typing Header
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: 0.0,
                          child: child,
                        );
                      },
                      child: _isLogin
                          ? _buildTypingText(
                              'Welcome Back',
                              key: const ValueKey('login'),
                            )
                          : _buildTypingText(
                              'Create Account',
                              key: const ValueKey('signup'),
                            ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _isLogin
                          ? 'Log in to access your intelligence portal'
                          : 'Create an account to get started',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Name Field (Signup only)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      ),
                      child: _isLogin
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                CustomTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Enter your name'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                    ),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty)
                              ? 'Please enter your password'
                              : null,
                    ),

                    // Confirm Password (Signup only)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      ),
                      child: _isLogin
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _confirmController,
                                  label: 'Confirm Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) {
                                    if (!_isLogin &&
                                        value !=
                                            _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                    ),

                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Submit Button with Flip Animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: _flipTransitionBuilder,
                      layoutBuilder: (widget, list) =>
                          Stack(children: [widget!, ...list]),
                      child: ElevatedButton(
                        key: ValueKey(_isLogin),
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(double.infinity, 50),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          _isLogin ? 'LOGIN' : 'SIGN UP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(children: const [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ]),

                    const SizedBox(height: 24),

                    // SocialLoginButton(
                    //   onPressed: _handleGoogleLogin,
                    //   label: _isLogin
                    //       ? 'Login with Google'
                    //       : 'Sign up with Google',
                    //   icon: Icons.g_mobiledata_rounded,
                    // ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style:
                              const TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: _toggleAuthMode,
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              decoration:
                                  TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingText(String text, {required Key key}) {
    return TweenAnimationBuilder<int>(
      
      key: key,
      tween: IntTween(begin: 0, end: text.length),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity, // <--- Forces the container to full width
          child:Text(
            text.substring(0, value),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          )
        );
      },
    );
  }

  Widget _flipTransitionBuilder(
      Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_isLogin) != widget!.key);

        var tilt =
            ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;

        final value = isUnder
            ? min(rotateAnim.value, pi / 2)
            : rotateAnim.value;

        return Transform(
          transform:
              Matrix4.rotationX(value)..setEntry(3, 1, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}