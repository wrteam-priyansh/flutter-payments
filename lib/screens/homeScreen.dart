import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payments/cubits/prePaymentTasksCubit.dart';
import 'package:payments/screens/paymentScreen.dart';
import 'package:payments/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PaymentGateway currentPaymentGateway = PaymentGateway.razorPay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
      ),
      body: ListView(
        children: [
          ListTile(
            trailing: currentPaymentGateway == PaymentGateway.razorPay
                ? Icon(Icons.check)
                : const SizedBox(),
            onTap: () {
              setState(() {
                currentPaymentGateway = PaymentGateway.razorPay;
              });
            },
            title: Text("Razorpay"),
          ),
          ListTile(
            trailing: currentPaymentGateway == PaymentGateway.paystack
                ? Icon(Icons.check)
                : const SizedBox(),
            onTap: () {
              setState(() {
                currentPaymentGateway = PaymentGateway.paystack;
              });
            },
            title: Text("Paystack"),
          ),
          ListTile(
            trailing: currentPaymentGateway == PaymentGateway.stripe
                ? Icon(Icons.check)
                : const SizedBox(),
            onTap: () {
              setState(() {
                currentPaymentGateway = PaymentGateway.stripe;
              });
            },
            title: Text("Stripe"),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
                "* This is just for demo purpose. In production we will have only one payment gateway"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => BlocProvider(
                          create: (context) => PrePaymentTasksCubit(),
                          child: PaymentScreen(
                              paymentGateway: currentPaymentGateway),
                        )));
              },
              child: Text("Continue"))
        ],
      ),
    );
  }
}
