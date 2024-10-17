import 'package:flutter/material.dart';

class FMShimmerWidget extends StatefulWidget {
  final Color color;
  final Widget child;

  const FMShimmerWidget({
    super.key,
    required this.child,
    this.color = Colors.grey,
  });

  @override
  FMShimmerWidgetState createState() => FMShimmerWidgetState();
}

class FMShimmerWidgetState extends State<FMShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animationValue;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController
      ..forward()
      ..repeat()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, _animationValue.value, 1],
          colors: [widget.color, widget.color.withOpacity(0.1), widget.color],
        ),
      ),
      child: widget.child,
    );
  }
}
