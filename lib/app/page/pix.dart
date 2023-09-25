import 'package:flutter/material.dart';
import '../util/color.dart';

class PixPage extends StatelessWidget {
  final String pixCode;
  final void Function() copy;
  final double altura;
  const PixPage(
      {Key? key,
      required this.pixCode,
      required this.copy,
      required this.altura})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Image.asset("assets/images/code_qr.png"),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              iconColor: primaryColorDark,
              trailing: const Icon(
                Icons.copy,
                size: 32,
              ),
              titleTextStyle: TextStyle(fontSize: 14, color: blackColor),
              onLongPress: () {
                copy();
              },
              onTap: () {
                copy();
              },
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(pixCode),
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: blackColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
