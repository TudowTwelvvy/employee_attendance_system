import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/core/router/app_router.dart';
import 'package:ui/core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Login'),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80.r,
              color: AppTheme.primaryColor,
            ),
            
            SizedBox(height: 20.h),
            
            Text(
              'Welcome Back!',
              
              style: AppTheme.headingMedium
            ),
            
            SizedBox(height: 10.h),
            
            
            Text(
              'Please sign in to continue',
              style: AppTheme.bodyLarge,
            ),
            
            SizedBox(height: 40.h),
            
            Padding( 
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
      
                ),
                
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  
                ),
                
                obscureText: true,
                
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            
            SizedBox(height: 24.h),

            SizedBox(
              width: 200.w,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRouter.home);
                },
                
                child: const Text(
                  'LOGIN',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}