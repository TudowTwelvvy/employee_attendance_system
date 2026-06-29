import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Private constructor - prevents creating instances of this class
  // We only use the static methods and properties
  AppTheme._();

  //COLORS 
  
  /// Primary brand color - used for buttons, app bar, active states
  /// This purple color represents trust, professionalism, and technology
  static const Color primaryColor = Color(0xFF6C63FF);
  
  /// Secondary color - used for accents, highlights, less important actions
  static const Color secondaryColor = Color(0xFF00BFA6);
  
  /// Background color for screens - clean white for readability
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  /// Surface color for cards, dialogs, elevated containers
  static const Color surfaceColor = Colors.white;
  
  /// Error color - red for validation errors, failed actions
  static const Color errorColor = Color(0xFFE53935);
  
  /// Success color - green for successful actions, checkmarks
  static const Color successColor = Color(0xFF43A047);
  
  /// Text color for headings - dark for contrast
  static const Color textPrimary = Color(0xFF212529);
  
  /// Text color for body text - slightly lighter
  static const Color textSecondary = Color(0xFF6C757D);
  
  /// Text color for hints, placeholders - light gray
  static const Color textHint = Color(0xFFADB5BD);
  
  /// Divider color - subtle lines between sections
  static const Color dividerColor = Color(0xFFE9ECEF);

  // TEXT STYLES
  
  /// Heading style - large, bold text for titles
  static TextStyle get headingLarge => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,  // Slightly tighter for headings
  );
  
  /// Heading style - medium size for section titles
  static TextStyle get headingMedium => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  /// Heading style - small for card titles, list headers
  static TextStyle get headingSmall => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,  // Semi-bold
    color: textPrimary,
  );
  
  /// Body text - large for important paragraphs
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,  // Line height for readability
  );
  
  /// Body text - standard size for most content
  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );
  
  /// Body text - small for captions, labels
  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: textHint,
  );
  
  /// Button text style - bold, clear
  static TextStyle get buttonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,  // Slightly spaced for readability
  );

  // THEME DATA
  static ThemeData get lightTheme {
    return ThemeData(
      //Use Material Design 3
      useMaterial3: true,
      
      //Primary color - affects AppBar, buttons, active states
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      
      // Scaffold background... the default screen background
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,  // Center the title
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,  // Title and icons
        elevation: 0,  // No shadow - flat design
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // ElevatedButton theme - primary action buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,  // Subtle shadow
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 14.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: buttonText,
        ),
      ),
      
      // TextButton theme - secondary actions (text only)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // OutlinedButton theme - alternative actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 14.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      
      // InputDecoration theme - text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: textHint,
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: textHint,
        ),
      ),
      
      // Card theme - for information cards
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 16.h,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}