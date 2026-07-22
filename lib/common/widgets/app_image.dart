import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';
import 'package:shimmer/shimmer.dart';

enum AppImageType { network, asset }

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.urlOrPath,
    this.type = AppImageType.network,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  final String urlOrPath;
  final AppImageType type;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget image;
    
    if (type == AppImageType.network) {
      image = CachedNetworkImage(
        imageUrl: urlOrPath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: theme.colorScheme.surface,
          highlightColor: theme.colorScheme.surfaceContainerHighest,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => errorWidget ?? Container(
          width: width,
          height: height,
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image),
        ),
      );
    } else {
      image = Image.asset(
        urlOrPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget ?? Container(
          width: width,
          height: height,
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    
    return image;
  }
}
