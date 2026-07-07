import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ui/core/router/app_router.dart';
import 'package:ui/core/theme/app_theme.dart';
//import 'features/auth/presentation/screens/login_screen.dart';

class App extends ConsumerWidget {
  //ConsumerWidget = a widget that can read Riverpod providers
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if running on web
    final isWeb = MediaQuery.of(context).size.width > 800;

    // WidgetRef = the "remote control" to access providers
    return ScreenUtilInit(
      //All sizes will be scaled relative to this
      designSize: isWeb ? const Size(1440, 900) : const Size(412, 914),
      minTextAdapt: true,
      splitScreenMode: true,

      //Rebuild when screen size changes (important for web)
      rebuildFactor: (old, data) => old != data,

      builder: (context, child) {
        return MaterialApp.router(
          // MaterialApp.router = special version for GoRouter
          // Instead of 'home', we use 'routerConfig'
          title: 'Employee Attendance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Connect GoRouter to MaterialApp
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
