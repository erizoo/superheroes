import 'package:flutter/material.dart';
import 'package:superheroes/model/alignment_info.dart';

class AlignmentWidget extends StatelessWidget {
  final AlignmentInfo alignmentInfo;
  const AlignmentWidget({
    Key? key,
    required this.alignmentInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
        quarterTurns: 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6),
          color: alignmentInfo.color,
          alignment: Alignment.center,
          child: Text(
            alignmentInfo.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ));
  }
}
