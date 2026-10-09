/// A photo with its aspect ratio, so the layout does not wait for it to load.
final class AppImage {
  final String path;
  final double aspectRatio;

  const AppImage(this.path, {required this.aspectRatio});
}

/// Photos from Unsplash, free to use under https://unsplash.com/license.
abstract final class AppImages {
  /// By Adam Vradenburg, https://unsplash.com/photos/GA09PKfRIQY.
  static const lake = AppImage('assets/images/lake.jpg', aspectRatio: 3 / 2);

  /// By John Rodenn Castillo, https://unsplash.com/photos/a9smyzW_1V4.
  static const waterfall = AppImage(
    'assets/images/waterfall.jpg',
    aspectRatio: 9 / 16,
  );
}
