import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:payments/cubits/prePaymentTasksCubit.dart';
import 'package:payments/screens/paymentResponseScreen.dart';
import 'package:payments/utils/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentGateway paymentGateway;
  PaymentScreen({Key? key, required this.paymentGateway}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double amount = 500.50;

  final Razorpay _razorpay = Razorpay();

  final PaystackPlugin _paystack = PaystackPlugin()
    ..initialize(publicKey: paystackPublicKey);

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);

    super.initState();
  }

  void _handleRazorPayPaymentSuccess(PaymentSuccessResponse response) {
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (_) => PaymentResponseScreen(
              errorMessage: "",
              metaData: {},
            )));
  }

  void _handleRazorPayPaymentError(PaymentFailureResponse response) {
    print(response.message);

    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (_) => PaymentResponseScreen(
              errorMessage: response.message ?? "Payment failed",
              metaData: {},
            )));
  }

  void _handleRazorPayExternalWallet(ExternalWalletResponse response) {}

  void openRazorPayGateway() async {
    final options = {
      'key': razorPayApiKey, //this should be come from server
      'amount': (amount * 100).toInt(),
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'currency': 'INR',
      'prefill': {
        'method': 'card',
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      }
    };
    _razorpay.open(options);
  }

  //
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  //Using package flutter_paystack
  void openPaystackPaymentGateway() async {
    Charge charge = Charge()
      ..amount = (amount * 100).toInt()
      ..reference = _getReference()
      ..currency = "NGN"
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = 'customer@email.com';

    CheckoutResponse response = await _paystack.checkout(
      context,
      method: CheckoutMethod.card,
      // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (_) => PaymentResponseScreen(
                errorMessage: "",
                metaData: {},
              )));
    } else {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (_) => PaymentResponseScreen(
                errorMessage: response.message,
                metaData: {},
              )));
    }
  }

  /*
  Using package pay_with_paystack
  void openPaystackPaymentGateway() async {
    PayWithPayStack()
        .now(
            context: context,
            secretKey: paystackSecretKey, //This should be store in server
            customerEmail: "popekabu@gmail.com",
            reference: DateTime.now().microsecondsSinceEpoch.toString(),
            currency: "NGN", //Add currency here
            paymentChannel: [
              "card"
            ], //"mobile_money", add mobile money (Only for ghana)
            amount: (amount * 100).toString(),
            transactionCompleted: () {
              print("Transaction Successful");
            },
            metaData: {},
            transactionNotCompleted: () {
              print("Transaction Not Successful!");
            })
        .then((value) {
      print(value.toString());
    });
  }
  */

  // void openStripGateway() async {
  //   final paymentMethod = await Stripe.instance.createPaymentMethod(
  //       PaymentMethodParams.card(paymentMethodData: PaymentMethodData()));

  //       Stripe.instance.
  // }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text("Amount - Rs.${amount.toStringAsFixed(2)}"),
              ),
            ),
            BlocConsumer<PrePaymentTasksCubit, PrePaymentTasksState>(
              listener: (context, state) {
                if (state is PrePaymentTasksSuccess) {
                  if (widget.paymentGateway == PaymentGateway.razorPay) {
                    openRazorPayGateway();
                  } else if (widget.paymentGateway == PaymentGateway.paystack) {
                    openPaystackPaymentGateway();
                  }
                } else if (state is PrePaymentTasksFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)));
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    if (state is PrePaymentTasksInProgress) {
                      return;
                    }
                    context
                        .read<PrePaymentTasksCubit>()
                        .performPrePaymentTasks();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10)),
                    height: 50,
                    width: MediaQuery.of(context).size.width * (0.8),
                    child: state is PrePaymentTasksInProgress
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          )
                        : Center(
                            child: Text(
                            "Make payment",
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          )),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
