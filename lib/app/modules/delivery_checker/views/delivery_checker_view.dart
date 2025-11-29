import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/delivery_checker_controller.dart';

class DeliveryCheckerView extends GetView<DeliveryCheckerController> {
  const DeliveryCheckerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeliveryCheckerView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DeliveryCheckerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
