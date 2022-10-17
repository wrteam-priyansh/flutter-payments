import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payments/data/repositories/ordersRepository.dart';

abstract class PrePaymentTasksState {}

class PrePaymentTasksInitial extends PrePaymentTasksState {}

class PrePaymentTasksInProgress extends PrePaymentTasksState {}

class PrePaymentTasksSuccess extends PrePaymentTasksState {
  final String orderId;
  final String? razorPayOrderId;

  PrePaymentTasksSuccess({required this.orderId, this.razorPayOrderId});
}

class PrePaymentTasksFailure extends PrePaymentTasksState {
  final String errorMessage;

  PrePaymentTasksFailure(this.errorMessage);
}

class PrePaymentTasksCubit extends Cubit<PrePaymentTasksState> {
  final OrderRepository _orderRepository = OrderRepository();

  PrePaymentTasksCubit() : super(PrePaymentTasksInitial());

  void performPrePaymentTasks() async {
    try {
      emit(PrePaymentTasksInProgress());

      final result = await _orderRepository.placeOrder();

      emit(PrePaymentTasksSuccess(
          orderId: result['orderId'],
          razorPayOrderId: result['razorPayOrderId']));
    } catch (e) {
      emit(PrePaymentTasksFailure(e.toString()));
    }
  }
}
