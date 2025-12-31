import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/delivery_store_model.dart';
import '../../../data/repositories/delivery_store_repository.dart';
import '../../../theme/design_system.dart';
import 'map_picker_page.dart';

class EditDeliveryStorePage extends StatefulWidget {
  final DeliveryStore? store;
  const EditDeliveryStorePage({Key? key, this.store}) : super(key: key);

  @override
  State<EditDeliveryStorePage> createState() => _EditDeliveryStorePageState();
}

class _EditDeliveryStorePageState extends State<EditDeliveryStorePage> {
  late Map<String, TextEditingController> openHourCtrls;
  late Map<String, TextEditingController> closeHourCtrls;
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  final _repository = DeliveryStoreRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController ownerCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController whatsappCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController deliveryRadiusCtrl;
  late TextEditingController freeDeliveryRadiusCtrl;
  late TextEditingController costPerKmCtrl;
  late TextEditingController minOrderCtrl;
  double selectedLat = -6.2088;
  double selectedLng = 106.8456;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    openHourCtrls = {
      for (var d in days)
        d: TextEditingController(text: s?.operationalHours?[d]?['open'] ?? ''),
    };
    closeHourCtrls = {
      for (var d in days)
        d: TextEditingController(text: s?.operationalHours?[d]?['close'] ?? ''),
    };
    nameCtrl = TextEditingController(text: s?.name ?? '');
    ownerCtrl = TextEditingController(text: s?.owner ?? '');
    addressCtrl = TextEditingController(text: s?.address ?? '');
    phoneCtrl = TextEditingController(text: s?.phone ?? '');
    whatsappCtrl = TextEditingController(text: s?.whatsapp ?? '');
    emailCtrl = TextEditingController(text: s?.email ?? '');
    deliveryRadiusCtrl = TextEditingController(
      text: s?.deliveryRadius.toString() ?? '10.0',
    );
    freeDeliveryRadiusCtrl = TextEditingController(
      text: s?.freeDeliveryRadius.toString() ?? '5.0',
    );
    costPerKmCtrl = TextEditingController(
      text: s?.deliveryCostPerKm.toString() ?? '2000',
    );
    minOrderCtrl = TextEditingController(
      text: s?.minOrder.toString() ?? '50000',
    );
    selectedLat = s?.latitude ?? -6.2088;
    selectedLng = s?.longitude ?? 106.8456;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    ownerCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    whatsappCtrl.dispose();
    emailCtrl.dispose();
    deliveryRadiusCtrl.dispose();
    freeDeliveryRadiusCtrl.dispose();
    costPerKmCtrl.dispose();
    minOrderCtrl.dispose();
    for (var ctrl in openHourCtrls.values) {
      ctrl.dispose();
    }
    for (var ctrl in closeHourCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final storeId =
          widget.store?.id ??
          '${DateTime.now().millisecondsSinceEpoch}-${nameCtrl.text.hashCode}';
      final operationalHours = {
        for (var d in days)
          d: {
            'open': openHourCtrls[d]?.text ?? '',
            'close': closeHourCtrls[d]?.text ?? '',
          },
      };
      final newStore = DeliveryStore(
        id: storeId,
        name: nameCtrl.text,
        owner: ownerCtrl.text,
        address: addressCtrl.text,
        latitude: selectedLat,
        longitude: selectedLng,
        phone: phoneCtrl.text,
        whatsapp: whatsappCtrl.text,
        email: emailCtrl.text,
        operationalHours: operationalHours,
        deliveryRadius: double.tryParse(deliveryRadiusCtrl.text) ?? 0.0,
        freeDeliveryRadius: double.tryParse(freeDeliveryRadiusCtrl.text) ?? 0.0,
        deliveryCostPerKm: int.tryParse(costPerKmCtrl.text) ?? 0,
        minOrder: int.tryParse(minOrderCtrl.text) ?? 0,
        isActive: true,
        createdAt: widget.store?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (widget.store != null) {
        await _repository.updateStore(storeId, newStore);
      } else {
        await _repository.addStore(newStore);
      }
      if (mounted) {
        Get.back(result: true);
        Get.snackbar(
          'Berhasil',
          'Toko berhasil disimpan',
          backgroundColor: DesignColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan toko: $e',
        backgroundColor: DesignColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.store != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Toko' : 'Tambah Toko'),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Nama Toko', nameCtrl),
                    _buildTextField('Pemilik', ownerCtrl),
                    _buildTextField('Alamat', addressCtrl),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: DesignColors.primary),
                        borderRadius: BorderRadius.circular(DesignRadius.small),
                        color: DesignColors.primary.withOpacity(0.06),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📍 Lokasi Toko',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${selectedLat.toStringAsFixed(4)}, Lng: ${selectedLng.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPickerPage(
                                      initialLat: selectedLat,
                                      initialLng: selectedLng,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    selectedLat = result.latitude;
                                    selectedLng = result.longitude;
                                  });
                                }
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('Pilih di Map'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: DesignColors.primary),
                        borderRadius: BorderRadius.circular(DesignRadius.small),
                        color: DesignColors.primary.withOpacity(0.06),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🕒 Jam Operasional',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...days.map(
                            (d) => Row(
                              children: [
                                SizedBox(width: 80, child: Text(d)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: openHourCtrls[d],
                                    decoration: const InputDecoration(
                                      labelText: 'Buka',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: closeHourCtrls[d],
                                    decoration: const InputDecoration(
                                      labelText: 'Tutup',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTextField('Telepon', phoneCtrl),
                    _buildTextField('WhatsApp', whatsappCtrl),
                    _buildTextField('Email', emailCtrl),
                    _buildTextField(
                      'Radius Pengiriman (km)',
                      deliveryRadiusCtrl,
                    ),
                    _buildTextField(
                      'Radius Gratis (km)',
                      freeDeliveryRadiusCtrl,
                    ),
                    _buildTextField('Biaya per KM (Rp)', costPerKmCtrl),
                    _buildTextField('Min Order (Rp)', minOrderCtrl),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignColors.primary,
                            ),
                            onPressed: _saveStore,
                            child: Text(isEdit ? 'Update' : 'Tambah'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}
