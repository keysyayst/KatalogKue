import 'package:get/get.dart';

class ContactController extends GetxController {
  // Observable variable
  final count = 0.obs;

  void increment() => count.value++;
}
