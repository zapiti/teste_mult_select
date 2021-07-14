import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayWidget extends StatefulWidget {
  final ExpandableController controller;
  final Widget expanded;
  final Widget collapsed;
  final double widgetHeightOver;
  final double maxSize;

  OverlayWidget(
      {required this.controller,
      required this.collapsed,
      required this.expanded,
      this.widgetHeightOver = 30,
      this.maxSize = 200});

  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  late OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final double percentToPage = 1.4;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        if (widget.controller.expanded) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context)!.insert(_overlayEntry!);
        } else {
          if (_overlayEntry != null) {
            _overlayEntry!.remove();
            _overlayEntry = null;
          }
        }
      }
    });
  }

  Size _getSizeRenderBox(RenderBox renderBox) {
    return renderBox.size;
  }

  double _getFinalSizeToPosition(RenderBox renderBox) {
    final position = renderBox.localToGlobal(Offset.zero);
    final size = _getSizeRenderBox(renderBox);
    final differencePosition = MediaQuery.of(context).size.height - position.dy;
    var sizeFinal = (size.height - widget.widgetHeightOver);

    if (differencePosition < widget.maxSize * percentToPage) {
      if (sizeFinal < widget.maxSize) {
        sizeFinal = widget.maxSize - sizeFinal + widget.widgetHeightOver;
      }
      return sizeFinal * percentToPage;
    } else {
      return -(sizeFinal);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = _getSizeRenderBox(renderBox);
    final sizeFinal = _getFinalSizeToPosition(renderBox);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, -sizeFinal),
          child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxSize),
                  child: widget.expanded)),
        ),
      ),
    );
  }

  void dismissOverLay() {
    if (!widget.controller.expanded) {
      widget.controller.value = true;
    } else {
      widget.controller.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: dismissOverLay,
        child: CompositedTransformTarget(
            link: _layerLink,
            child: Stack(children: <Widget>[
              widget.collapsed,
              Container(
                color: Colors.transparent,
              )
            ])));
  }
}
