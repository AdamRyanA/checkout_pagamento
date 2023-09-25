import 'package:flutter/material.dart';
import '../util/color.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> card;
  const CardPage({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text("Cartão".toUpperCase()),
          centerTitle: true,
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: Column(
              children: [
                Image.asset(
                  "${card['image']}",
                  width: 200,
                  height: 200,
                ),
                Text(
                  "${card['tipoCard']}",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                    "•••• ${card['numberCard'].substring(card['numberCard'].length - 4)}",
                    style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ));
  }
}
