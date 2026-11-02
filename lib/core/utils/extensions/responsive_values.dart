import 'package:flutter/material.dart'; // Preferred over cupertino for EdgeInsets/BorderRadius

import 'responsive_size.dart';

extension ResponsiveUIValues on BuildContext {
  // SPACING SCALE (Base values)
  double get spaceXxs => setSize(2.0);
  double get spaceXs => setSize(4.0);
  double get spaceS => setSize(8.0);
  double get spaceM => setSize(12.0);
  double get spaceL => setSize(16.0);
  double get spaceXl => setSize(24.0);
  double get spaceXxl => setSize(32.0);
  double get spaceXxxl => setSize(48.0);
  double get spaceXxxxl => setSize(64.0);

  // INSETS (All)
  EdgeInsets get insetsAllXs => EdgeInsets.all(spaceXs);
  EdgeInsets get insetsAllS => EdgeInsets.all(spaceS);
  EdgeInsets get insetsAllM => EdgeInsets.all(spaceM);
  EdgeInsets get insetsAllL => EdgeInsets.all(spaceL);
  EdgeInsets get insetsAllXl => EdgeInsets.all(spaceXl);
  EdgeInsets get insetsAllXxl => EdgeInsets.all(spaceXxl);

  // INSETS (Symmetric)
  EdgeInsets get insetsHorizontalXs =>
      EdgeInsets.symmetric(horizontal: spaceXs);
  EdgeInsets get insetsHorizontalXxs =>
      EdgeInsets.symmetric(horizontal: spaceXxs);
  EdgeInsets get insetsHorizontalS => EdgeInsets.symmetric(horizontal: spaceS);
  EdgeInsets get insetsHorizontalM => EdgeInsets.symmetric(horizontal: spaceM);
  EdgeInsets get insetsHorizontalL => EdgeInsets.symmetric(horizontal: spaceL);
  EdgeInsets get insetsHorizontalXl =>
      EdgeInsets.symmetric(horizontal: spaceXl);

  EdgeInsets get insetsVerticalXxs => EdgeInsets.symmetric(vertical: spaceXxs);
  EdgeInsets get insetsVerticalXs => EdgeInsets.symmetric(vertical: spaceXs);
  EdgeInsets get insetsVerticalS => EdgeInsets.symmetric(vertical: spaceS);
  EdgeInsets get insetsVerticalM => EdgeInsets.symmetric(vertical: spaceM);
  EdgeInsets get insetsVerticalL => EdgeInsets.symmetric(vertical: spaceL);
  EdgeInsets get insetsVerticalXl => EdgeInsets.symmetric(vertical: spaceXl);

  // RADIUS VALUES
  double get radiusXs => setSize(4.0);
  double get radiusS => setSize(8.0);
  double get radiusM => setSize(12.0);
  double get radiusL => setSize(16.0);
  double get radiusXl => setSize(24.0);
  double get radiusXxl => setSize(32.0);
  double get radiusCircular => 999.0; // Standard pill/circular shape

  // BORDER RADIUS
  BorderRadius get brXs => BorderRadius.circular(radiusXs);
  BorderRadius get brS => BorderRadius.circular(radiusS);
  BorderRadius get brM => BorderRadius.circular(radiusM);
  BorderRadius get brL => BorderRadius.circular(radiusL);
  BorderRadius get brXl => BorderRadius.circular(radiusXl);
  BorderRadius get brXxl => BorderRadius.circular(radiusXxl);
  BorderRadius get brCircular => BorderRadius.circular(radiusCircular);

  // ICON SIZES
  double get iconXs => setSize(12.0);
  double get iconS => setSize(16.0);
  double get iconM => setSize(20.0);
  double get iconL => setSize(24.0);
  double get iconXl => setSize(30.0);
  double get iconXxl => setSize(36.0);

  // ELEVATIONS
  double get elevationNone => 0.0;
  double get elevationS => 2.0;
  double get elevationM => 4.0;
  double get elevationL => 8.0;
  double get elevationXl => 16.0;

  // SPACING WIDGETS
  SizedBox verticalSpace(double height) => SizedBox(height: setSize(height));
  SizedBox horizontalSpace(double width) => SizedBox(width: setSize(width));
}
