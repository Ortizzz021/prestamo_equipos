import 'package:flutter/material.dart';

class ImagenEquipo extends StatelessWidget {
  const ImagenEquipo({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url.isEmpty
            ? const _Placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progreso) => progreso == null
                    ? child
                    : const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (context, error, stack) => const _Placeholder(),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colores.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.devices_other, color: colores.onSurfaceVariant),
      ),
    );
  }
}
