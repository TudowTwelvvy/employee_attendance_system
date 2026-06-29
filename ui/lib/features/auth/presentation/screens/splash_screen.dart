import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState(); 
 
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {  // Check if widget is still on screen
        context.go(AppRouter.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            // Company Logo Icon
            Icon(
              Icons.fingerprint,
              size: 120.r,  
              color: Colors.white,
            ),
            
            SizedBox(height: 24.h),  // Spacing
            
            // App Name
            Text(
              'Employee Attendance',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8.h),  // Small spacing
            
            // Tagline
            Text(
              'Track. Verify. Report.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.8),
                // withOpacity(0.8) = 80% white, 20% transparent
                letterSpacing: 2, 
              ),
            ),
            
            SizedBox(height: 48.h),  // Large spacing
            
            
            SizedBox(
              width: 40.r,
              height: 40.r,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,  
              ),
            ),
            
            SizedBox(height: 16.h),
            
           
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}