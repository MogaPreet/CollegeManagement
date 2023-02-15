import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProgressIndication extends StatefulWidget {
  const ProgressIndication({super.key});

  @override
  State<ProgressIndication> createState() => _ProgressIndicationState();
}

class _ProgressIndicationState extends State<ProgressIndication> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
