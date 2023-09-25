import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'app/page/checkout_payment_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Checkout',
      debugShowCheckedModeBanner: false,
      home: CheckoutPaymentPage(),
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
