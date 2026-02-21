import 'package:flutter/material.dart';

abstract class UIConstants {
  // Padding values
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;

  // Margin values (same as padding for consistency)
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 12.0;
  static const double marginL = 16.0;
  static const double marginXL = 20.0;
  static const double marginXXL = 24.0;
  static const double marginXXXL = 32.0;

  // Spacing (for SizedBox)
  static const double spacingXS = 2.0;
  static const double spacingS = 4.0;
  static const double spacingM = 8.0;
  static const double spacingL = 12.0;
  static const double spacingXL = 16.0;
  static const double spacingXXL = 20.0;
  static const double spacingXXXL = 24.0;

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircular = 50.0;

  // Icon sizes
  static const double iconXS = 14.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 28.0;
  static const double iconXXL = 32.0;
  static const double iconLarge = 48.0;
  static const double iconHuge = 64.0;

  // Font sizes
  static const double fontXS = 10.0;
  static const double fontS = 11.0;
  static const double fontM = 12.0;
  static const double fontL = 14.0;
  static const double fontXL = 16.0;
  static const double fontXXL = 18.0;
  static const double fontXXXL = 20.0;
  static const double fontHeading = 24.0;
  static const double fontTitle = 28.0;

  // Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;

  // Card elevation
  static const double elevationNone = 0.0;
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;

  // Border width
  static const double borderWidthThin = 0.5;
  static const double borderWidthNormal = 1.0;
  static const double borderWidthThick = 2.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 1000);

  // Snackbar duration
  static const Duration snackbarShort = Duration(seconds: 2);
  static const Duration snackbarNormal = Duration(seconds: 3);
  static const Duration snackbarLong = Duration(seconds: 4);

  // Connection indicator size
  static const double connectionIndicatorSize = 12.0;

  // Progress indicator stroke width
  static const double progressStrokeS = 2.0;
  static const double progressStrokeM = 3.0;
  static const double progressStrokeL = 4.0;

  // Avatar/Badge sizes
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 48.0;
  static const double avatarXL = 64.0;

  // List item heights
  static const double listItemHeightS = 48.0;
  static const double listItemHeightM = 56.0;
  static const double listItemHeightL = 72.0;

  // Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 8.0,
    vertical: 4.0,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: 16.0,
  );

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );

  // Dialog constraints
  static const double dialogMinWidth = 280.0;
  static const double dialogMaxWidth = 400.0;

  // Max lines for text
  static const int maxLinesTitle = 2;
  static const int maxLinesBody = 3;
  static const int maxLinesDescription = 5;
}

class AppPadding {
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets allXS = EdgeInsets.all(UIConstants.paddingXS);
  static const EdgeInsets allS = EdgeInsets.all(UIConstants.paddingS);
  static const EdgeInsets allM = EdgeInsets.all(UIConstants.paddingM);
  static const EdgeInsets allL = EdgeInsets.all(UIConstants.paddingL);
  static const EdgeInsets allXL = EdgeInsets.all(UIConstants.paddingXL);

  static const EdgeInsets horizontalS = EdgeInsets.symmetric(
    horizontal: UIConstants.paddingS,
  );
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(
    horizontal: UIConstants.paddingM,
  );
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(
    horizontal: UIConstants.paddingL,
  );

  static const EdgeInsets verticalS = EdgeInsets.symmetric(
    vertical: UIConstants.paddingS,
  );
  static const EdgeInsets verticalM = EdgeInsets.symmetric(
    vertical: UIConstants.paddingM,
  );
  static const EdgeInsets verticalL = EdgeInsets.symmetric(
    vertical: UIConstants.paddingL,
  );
}

class AppRadius {
  static final BorderRadius zero = BorderRadius.zero;
  static final BorderRadius xs = BorderRadius.circular(UIConstants.radiusXS);
  static final BorderRadius s = BorderRadius.circular(UIConstants.radiusS);
  static final BorderRadius m = BorderRadius.circular(UIConstants.radiusM);
  static final BorderRadius l = BorderRadius.circular(UIConstants.radiusL);
  static final BorderRadius xl = BorderRadius.circular(UIConstants.radiusXL);
  static final BorderRadius circular = BorderRadius.circular(
    UIConstants.radiusCircular,
  );
}
