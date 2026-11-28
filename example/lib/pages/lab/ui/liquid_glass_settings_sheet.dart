import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

/// Keeps the optional overrides so the preview can use the theme's defaults.
typedef GlassPreviewSettings = ({
  SmartContextMenuGlassStyle style,
  SmartContextMenuBlur? blur,
  double? edgeHighlight,
});

const GlassPreviewSettings defaultGlassPreviewSettings = (
  style: SmartContextMenuGlassStyle(),
  blur: null,
  edgeHighlight: null,
);

final class LiquidGlassSettingsSheet extends StatefulWidget {
  final GlassPreviewSettings settings;

  const LiquidGlassSettingsSheet({super.key, required this.settings});

  @override
  State<LiquidGlassSettingsSheet> createState() =>
      _LiquidGlassSettingsSheetState();
}

final class _LiquidGlassSettingsSheetState
    extends State<LiquidGlassSettingsSheet> {
  late var _style = widget.settings.style;
  late var _blur = widget.settings.blur;
  late var _edgeHighlight = widget.settings.edgeHighlight;
  late final _tintInput = TextEditingController(text: _hexRgb(_resolvedTint));

  Color get _resolvedTint =>
      CupertinoDynamicColor.resolve(_style.color, context);

  static String _hexRgb(Color color) => (color.toARGB32() & 0xFFFFFF)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_style.color is CupertinoDynamicColor && _tintInput.text.length == 6) {
      final tint = _hexRgb(_resolvedTint);
      if (tint != _tintInput.text) _tintInput.text = tint;
    }
  }

  @override
  void dispose() {
    _tintInput.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _style = defaultGlassPreviewSettings.style;
      _blur = defaultGlassPreviewSettings.blur;
      _edgeHighlight = defaultGlassPreviewSettings.edgeHighlight;
      _tintInput.text = _hexRgb(_resolvedTint);
    });
  }

  void _setTintRgb(String value) {
    setState(() {
      if (value.length == 6) {
        final color = Color(0xFF000000 | int.parse(value, radix: 16));
        _style = _style.copyWith(
          color: color.withValues(alpha: _resolvedTint.a),
        );
      }
    });
  }

  void _setTintOpacity(double alpha) {
    final tint = _style.color;
    final color = tint is CupertinoDynamicColor
        ? CupertinoDynamicColor.withBrightness(
            color: tint.color.withValues(alpha: alpha),
            darkColor: tint.darkColor.withValues(alpha: alpha),
          )
        : tint.withValues(alpha: alpha);
    setState(() => _style = _style.copyWith(color: color));
  }

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final direction = _style.lightDirection.direction * 180 / math.pi;
    final tintIsValid = _tintInput.text.length == 6;
    // The public getters expose the light defaults. The preview keeps the
    // dark defaults automatic until the user changes either slider.
    final blur = _blur?.sigmaX ?? (dark ? 1.8 : _style.blur.sigmaX);
    final highlight = _edgeHighlight ?? (dark ? 0.45 : _style.edgeHighlight);

    final options = ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        CupertinoListSection.insetGrouped(
          header: const Text('Optics'),
          children: [
            _slider(
              'Local blur',
              value: blur,
              max: 12,
              divisions: 120,
              display: blur.toStringAsFixed(1),
              onChanged: (value) =>
                  setState(() => _blur = SmartContextMenuBlur(value)),
            ),
            _slider(
              'Refraction',
              value: _style.refraction,
              max: 3,
              divisions: 60,
              display: '${_style.refraction.toStringAsFixed(2)}×',
              onChanged: (value) =>
                  setState(() => _style = _style.copyWith(refraction: value)),
            ),
            _slider(
              'Edge highlight',
              value: highlight,
              max: 3,
              divisions: 60,
              display: '${highlight.toStringAsFixed(2)}×',
              onChanged: (value) => setState(() => _edgeHighlight = value),
            ),
            _slider(
              'Rim width',
              value: _style.rimWidth,
              max: 16,
              divisions: 160,
              display: '${_style.rimWidth.toStringAsFixed(1)} px',
              onChanged: (value) =>
                  setState(() => _style = _style.copyWith(rimWidth: value)),
            ),
            _slider(
              'Bevel width',
              value: _style.bevelWidth,
              max: 48,
              divisions: 48,
              display: '${_style.bevelWidth.toStringAsFixed(0)} px',
              onChanged: (value) =>
                  setState(() => _style = _style.copyWith(bevelWidth: value)),
            ),
            _slider(
              'Light direction',
              value: direction,
              min: -180,
              max: 180,
              divisions: 360,
              display: '${direction.round()}°',
              onChanged: (value) => setState(
                () => _style = _style.copyWith(
                  lightDirection: Offset.fromDirection(value * math.pi / 180),
                ),
              ),
            ),
          ],
        ),
        CupertinoListSection.insetGrouped(
          header: const Text('Tint'),
          children: [
            CupertinoListTile(
              title: const Text('Tint color'),
              subtitle: tintIsValid ? null : const Text('Enter six hex digits'),
              trailing: SizedBox(
                width: 116,
                child: CupertinoTextField(
                  controller: _tintInput,
                  prefix: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: Text('#'),
                  ),
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                  ],
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  onChanged: _setTintRgb,
                ),
              ),
            ),
            _slider(
              'Tint opacity',
              value: _resolvedTint.a,
              max: 1,
              divisions: 100,
              display: '${(_resolvedTint.a * 100).round()}%',
              onChanged: _setTintOpacity,
            ),
          ],
        ),
        CupertinoButton(onPressed: _reset, child: const Text('Reset')),
      ],
    );

    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    final maxHeight = math.min(
      media.size.height * 0.8,
      math.max(0.0, media.size.height - media.viewPadding.top - keyboardInset),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: ColoredBox(
            color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        CupertinoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        Expanded(
                          child: Text(
                            'Glass settings',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CupertinoTheme.of(
                              context,
                            ).textTheme.navTitleTextStyle,
                          ),
                        ),
                        CupertinoButton(
                          onPressed: !tintIsValid
                              ? null
                              : () => Navigator.of(context)
                                    .pop<GlassPreviewSettings>((
                                      style: _style,
                                      blur: _blur,
                                      edgeHighlight: _edgeHighlight,
                                    )),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),
                  Flexible(child: options),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slider(
    String title, {
    required double value,
    double min = 0,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text(
                display,
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: title,
              child: CupertinoSlider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
