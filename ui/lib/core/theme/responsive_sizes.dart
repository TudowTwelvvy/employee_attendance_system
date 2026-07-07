import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ResponsiveSizes provides size values that adapt to mobile vs web.
///
/// On mobile (narrow screens): Uses flutter_screenutil values
/// On web/desktop (wide screens): Uses fixed, reasonable values
class ResponsiveSizes {
  final BuildContext context;

  ResponsiveSizes(this.context);

  /// True if screen is wider than 800px (desktop/tablet landscape)
  bool get isDesktop => MediaQuery.of(context).size.width > 800;

  /// Screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Max content width for desktop (prevents stretching)
  double get maxContentWidth => isDesktop ? 1200 : screenWidth;

  /// Horizontal padding
  /// Mobile: 24 logical pixels
  /// Desktop: 48 logical pixels (more breathing room)
  double get paddingHorizontal => isDesktop ? 48 : 24.w;

  /// Vertical padding
  /// Mobile: scales with screen
  /// Desktop: fixed comfortable value
  double get paddingVertical => isDesktop ? 32 : 24.h;

  /// Standard card padding
  double get cardPadding => isDesktop ? 24 : 16.w;

  /// Button height
  /// Mobile: 50 logical pixels
  /// Desktop: 48 fixed (standard desktop button)
  double get buttonHeight => isDesktop ? 48 : 50.h;

  /// Heading font size
  /// Mobile: 24.sp (scales)
  /// Desktop: 28 fixed (readable but not huge)
  double get headingSize => isDesktop ? 28 : 24.sp;

  /// Body font size
  /// Mobile: 16.sp
  /// Desktop: 16 fixed (standard web text)
  double get bodySize => isDesktop ? 16 : 16.sp;

  /// Small font size
  double get smallSize => isDesktop ? 14 : 14.sp;

  /// Icon size (large)
  double get iconLarge => isDesktop ? 64 : 80.r;

  /// Icon size (medium)
  double get iconMedium => isDesktop ? 24 : 20.r;

  /// Border radius
  double get borderRadius => isDesktop ? 12 : 12.r;

  /// Spacing (small)
  double get spaceSmall => isDesktop ? 8 : 8.h;

  /// Spacing (medium)
  double get spaceMedium => isDesktop ? 16 : 16.h;

  /// Spacing (large)
  double get spaceLarge => isDesktop ? 32 : 32.h;

  /// Creates a centered, max-width container for desktop
  Widget centeredContent({required Widget child}) {
    if (!isDesktop) return child; // Mobile: full width

    // Desktop: center with max width
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
