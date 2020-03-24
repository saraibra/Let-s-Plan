import 'package:flutter/material.dart';

const BoxConstraints _kMinSizeConstraints =
    BoxConstraints.tightFor(width: 52.0, height: 52.0);
const BoxConstraints _kSizeConstraints =
    BoxConstraints.tightFor(width: 68.0, height: 68.0);

class DiamondFab extends StatefulWidget {
  final Widget child;
  final double notchMargin;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final String tooltip;
  final VoidCallback onPressed;
  final Object heroTag;
  final double highlightElevation;
  final bool mini;
  final BoxConstraints boxConstraints;

  const DiamondFab(
      {Key key,
      this.notchMargin: 8.0,
      this.backgroundColor,
      this.foregroundColor,
      this.elevation:6.0,
      this.tooltip,
      @required this.onPressed,
      this.heroTag: const _DefaultHeroTag(),
      this.highlightElevation: 12.0,
      this.mini: false,
      this.child})
      : assert(
          elevation != null,
        ),
        assert(highlightElevation != null),
        assert(mini != null),
        assert(notchMargin != null),
        boxConstraints = mini ? _kMinSizeConstraints : _kSizeConstraints,
        super(key: key);
  @override
  _DiamondFabState createState() => _DiamondFabState();
}

class _DiamondFabState extends State<DiamondFab> {
  bool _hightlight = false;
  VoidCallback _notchChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foregroundColor =
        widget.foregroundColor ?? theme.accentIconTheme.color;
    Widget result;
    if (widget.child != null) {
      result = IconTheme.merge(
          data: IconThemeData(color: foregroundColor), child: widget.child);
    }
    if (widget.tooltip != null) {
      final Widget toolTip = Tooltip(
        message: widget.tooltip,
        child: result,
      );
      result = widget.child != null
          ? toolTip
          : SizedBox.expand(
              child: toolTip,
            );
    }
    result = RawMaterialButton(
      onPressed: widget.onPressed,
      onHighlightChanged: _handleHightHandChanged,
      elevation: _hightlight ? widget.highlightElevation : widget.elevation,
      constraints: widget.boxConstraints,
      fillColor: widget.backgroundColor ?? theme.accentColor,
      textStyle: theme.accentTextTheme.button
          .copyWith(color: foregroundColor, letterSpacing: 1.2),
      shape: _DiamondBorder(),
      child: result,
    );

    return result;
  }

  @override
  void deactivate() {
    if (_notchChanged != null) {
      _notchChanged();
    }
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _handleHightHandChanged(bool value) {
     setState(() => _hightlight = value);
  }
}

class _DiamondBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only();

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.right, rect.top + rect.height / 2.0)
      ..lineTo(rect.left + rect.width / 2.0, rect.bottom)
      ..lineTo(rect.left, rect.top + rect.height / 2.0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return null;
  }
}

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionButton tag >';
}
