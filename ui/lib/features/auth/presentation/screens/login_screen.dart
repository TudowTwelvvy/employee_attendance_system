import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Used to validate all fields at once
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              // Form = groups multiple form fields together
              // Enables validation of all fields at once
              key: _formKey,
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                
                children: [
                  // Logo
                 Image.asset(
                     'assets/images/TraBSLogo.png', 
                      height: 150.h,
                    ),
              
                  
                  SizedBox(height: 24.h),
                  
                  // Title
                  Text(
                    'Welcome Back!',
                    style: AppTheme.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Subtitle
                  Text(
                    'Sign in to your account',
                    style: AppTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    
                    keyboardType: TextInputType.emailAddress,
                    
                    // Validator = checks if input is valid
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;  // Valid!
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    
                    obscureText: true,  // Hide password
                    
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Forgot Password
                  Align(
                    // Align = positions child within available space
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        //nagivate too forgotpassword
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Login Button
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
      
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('LOGIN'),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(AppRouter.register);
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}