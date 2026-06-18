import 'package:flutter_stripe/flutter_stripe.dart';

class WholesaleStripePaymentSheetResult {
  final bool completed;
  final bool cancelled;
  final String? message;

  const WholesaleStripePaymentSheetResult._({
    required this.completed,
    required this.cancelled,
    this.message,
  });

  const WholesaleStripePaymentSheetResult.completed()
      : this._(completed: true, cancelled: false);

  const WholesaleStripePaymentSheetResult.cancelled([String? message])
      : this._(completed: false, cancelled: true, message: message);

  const WholesaleStripePaymentSheetResult.failed(String message)
      : this._(completed: false, cancelled: false, message: message);
}

class WholesaleStripePaymentSheet {
  static Future<WholesaleStripePaymentSheetResult> present({
    required String publishableKey,
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    if (publishableKey.trim().isEmpty || clientSecret.trim().isEmpty) {
      return const WholesaleStripePaymentSheetResult.failed(
        'Stripe payment details are missing. Please try again.',
      );
    }

    try {
      Stripe.publishableKey = publishableKey.trim();
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret.trim(),
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return const WholesaleStripePaymentSheetResult.completed();
    } on StripeException catch (e) {
      final code = e.error.code.toString().toLowerCase();
      if (code.contains('canceled') || code.contains('cancelled')) {
        return const WholesaleStripePaymentSheetResult.cancelled(
          'Payment was cancelled. Your cart is still available.',
        );
      }

      return WholesaleStripePaymentSheetResult.failed(
        e.error.localizedMessage ?? 'Stripe payment failed. Please try again.',
      );
    } catch (e) {
      return WholesaleStripePaymentSheetResult.failed(e.toString());
    }
  }
}
