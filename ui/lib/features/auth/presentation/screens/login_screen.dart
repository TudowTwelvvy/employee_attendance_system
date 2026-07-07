import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).login(email, password);

    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // On desktop: limit width and add card effect
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 480 : double.infinity,
              ),
              margin: EdgeInsets.all(isDesktop ? 48 : 24.w),
              padding: EdgeInsets.all(isDesktop ? 48 : 24.w),
              decoration: isDesktop
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    )
                  : null, // No card on mobile (full width)
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/TraBSLogo.png',
                      height: isDesktop ? 200 : 150.h,
                      width: isDesktop ? 200 : 150.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isDesktop ? 24 : 24.h),

                    // Title
                    Text(
                      'Welcome Back!',
                      style: AppTheme.headingMedium(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 8 : 8.h),

                    // Subtitle
                    Text(
                      'Sign in to your account',
                      style: AppTheme.bodyLarge(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 32 : 32.h),

                    // Error message
                    if (authState.errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 12 : 12.w),
                        margin: EdgeInsets.only(bottom: isDesktop ? 16 : 16.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isDesktop ? 14 : 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        // Web: larger text for readability
                        labelStyle: TextStyle(fontSize: isDesktop ? 16 : 16.sp),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: isDesktop ? 16 : 16.sp),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter email';
                        if (!value!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    SizedBox(height: isDesktop ? 16 : 16.h),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        labelStyle: TextStyle(fontSize: isDesktop ? 16 : 16.sp),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: isDesktop ? 16 : 16.sp),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter password';
                        }
                        if (value!.length < 6) return 'Password too short';
                        return null;
                      },
                    ),
                    SizedBox(height: isDesktop ? 8 : 8.h),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: isDesktop ? 14 : 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 24.h),

                    // Login button
                    SizedBox(
                      height: isDesktop ? 48 : 50.h,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 16.h),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTheme.bodyMedium(context),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRouter.register),
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
      ),
    );
  }
}
