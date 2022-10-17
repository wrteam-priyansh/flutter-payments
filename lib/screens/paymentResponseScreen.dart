import 'package:flutter/material.dart';

class PaymentResponseScreen extends StatefulWidget {
  final Map<String, dynamic> metaData;
  final String errorMessage;
  PaymentResponseScreen(
      {Key? key, required this.errorMessage, required this.metaData})
      : super(key: key);

  @override
  State<PaymentResponseScreen> createState() => _PaymentResponseScreenState();
}

class _PaymentResponseScreenState extends State<PaymentResponseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment response"),
      ),
      body: Center(
        child: widget.errorMessage.isEmpty
            ? Text("Success")
            : Column(
                children: [
                  Text("Failure"),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(widget.errorMessage)
                ],
              ),
      ),
    );
  }
}
