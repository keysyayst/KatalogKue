import 'package:get/get.dart';

class FirebaseMessagingProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'YOUR-API-URL';
  }
}
