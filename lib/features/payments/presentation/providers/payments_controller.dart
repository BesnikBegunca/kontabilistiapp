import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../../../domain/entities/payment_entity.dart';
import '../../../../domain/usecases/payments/payment_usecases.dart';

final paymentsSearchProvider = StateProvider<String>((ref) => '');

final paymentsControllerProvider =
    AsyncNotifierProvider<PaymentsController, List<PaymentEntity>>(PaymentsController.new);

class PaymentsController extends AsyncNotifier<List<PaymentEntity>> {
  late final GetPaymentsUseCase _get;

  @override
  Future<List<PaymentEntity>> build() async {
    _get = GetPaymentsUseCase(ref.read(paymentRepositoryProvider));
    return _get(search: ref.watch(paymentsSearchProvider));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _get(search: ref.read(paymentsSearchProvider)));
  }
}
