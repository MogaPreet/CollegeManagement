import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashBoardCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;

  const DashBoardCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.44,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              subTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
