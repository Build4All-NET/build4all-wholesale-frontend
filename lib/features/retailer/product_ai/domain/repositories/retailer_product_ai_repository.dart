abstract class RetailerProductAiRepository {
  Future<String> chatAboutProduct({
    required int productId,
    required String message,
  });
}
