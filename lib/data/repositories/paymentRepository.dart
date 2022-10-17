import 'package:payments/utils/api.dart';

class PaymentRepository {
  Future<void> getAllPayments() async {
    try {
      final result = await Api.get(
          throwErrorOnSuccessResponse: false,
          headers: Api.razorPayHeaders(),
          url: "https://api.razorpay.com/v1/payments/",
          useAuthToken: false);

      print(result.keys);
    } catch (e) {
      print(e.toString());
    }
  }
}
