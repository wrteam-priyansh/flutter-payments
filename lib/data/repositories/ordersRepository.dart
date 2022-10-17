import 'package:flutter/foundation.dart';

class OrderRepository {
  //Place order, It should return orderId and other metadata that will be userful for making payment
  Future<Map<String, dynamic>> placeOrder() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      return {
        "orderId": "123",
        "razorPayOrderId": "456", //Only if we are using razorpay
      };
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Exception("Failed to place order");
    }
  }
}
