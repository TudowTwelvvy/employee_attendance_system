import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ui/core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      //All sizes will be scaled relative to this
      designSize: const Size(412, 914),
      minTextAdapt: true,
      splitScreenMode: true,
      
      child: MaterialApp(
        title: 'Employee Attendance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        home: const LoginScreen(), 
      ),
    );
  }
}