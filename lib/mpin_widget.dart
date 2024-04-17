import 'package:flutter/material.dart';
import 'package:flutter_mpin_animation/mpin_animation.dart';

class MPinController {
  void Function(String) addInput;
  void Function() delete;
  void Function() notifyWrongInput;
}

class MPinWidget extends StatefulWidget {
  final int pinLength;
  final MPinController controller;
  final Function(String)? onCompleted;

  const MPinWidget({
    Key? key,
    required this.pinLength,
    required this.controller,
    this.onCompleted,
  }) : super(key: key);

  @override
  _MPinWidgetState createState() => _MPinWidgetState();
}

class _MPinWidgetState extends State<MPinWidget>
    with SingleTickerProviderStateMixin {
  late List<MPinAnimationController> _animationControllers;
  late AnimationController _wrongInputAnimationController;
  late Animation<double> _wiggleAnimation;
  String mPin = '';

  @override
  void initState() {
    super.initState();
    _animationControllers =
        List.generate(widget.pinLength, (index) => MPinAnimationController());

    _wrongInputAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          _wrongInputAnimationController.reverse();
      });

    _wiggleAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _wrongInputAnimationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _wrongInputAnimationController.dispose();
    super.dispose();
  }

  void addInput(String input) async {
    mPin += input;
    if (mPin.length <= widget.pinLength) {
      _animationControllers[mPin.length - 1].animate(input);
    }

    if (mPin.length == widget.pinLength) {
      widget.onCompleted?.call(mPin);
      mPin = '';
    }
  }

  void delete() {
    if (mPin.isNotEmpty) {
      mPin = mPin.substring(0, mPin.length - 1);
      _animationControllers[mPin.length].animate('');
    }
  }

  void notifyWrongInput() {
    _wrongInputAnimationController.forward();
    _animationControllers.forEach((controller) {
      controller?.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_wiggleAnimation.value, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.pinLength, (index) {
          return MPinAnimation(
            controller: _animationControllers[index],
          );
        }),
      ),
    );
  }
}
