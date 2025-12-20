import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/delivery_store_model.dart';
import '../../../data/repositories/delivery_store_repository.dart';
import '../../../theme/design_system.dart';
import '../../delivery_checker/controllers/delivery_checker_controller.dart';
import 'map_picker_page.dart';

class AdminDeliveryStoresPage extends StatefulWidget {
  const AdminDeliveryStoresPage({Key? key}) : super(key: key);

  @override
  State<AdminDeliveryStoresPage> createState() =>
      _AdminDeliveryStoresPageState();
}

class _AdminDeliveryStoresPageState extends State<AdminDeliveryStoresPage> {
  final DeliveryStoreRepository _repository = DeliveryStoreRepository();
  final List<DeliveryStore> _stores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stores = await _repository.getAllStores();
      setState(() {
        _stores.clear();
        _stores.addAll(stores);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  void _showAddStoreDialog({DeliveryStore? store}) {
    final isEdit = store != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: store?.name ?? '');
    final ownerCtrl = TextEditingController(text: store?.owner ?? '');
    final addressCtrl = TextEditingController(text: store?.address ?? '');
    double selectedLat = store?.latitude ?? -6.2088;
    double selectedLng = store?.longitude ?? 106.8456;
    final phoneCtrl = TextEditingController(text: store?.phone ?? '');
    final whatsappCtrl = TextEditingController(text: store?.whatsapp ?? '');
    final emailCtrl = TextEditingController(text: store?.email ?? '');
    final deliveryRadiusCtrl = TextEditingController(
      text: store?.deliveryRadius.toString() ?? '10.0',
    );
    final freeDeliveryRadiusCtrl = TextEditingController(
      text: store?.freeDeliveryRadius.toString() ?? '5.0',
    );
    final costPerKmCtrl = TextEditingController(
      text: store?.deliveryCostPerKm.toString() ?? '2000',
    );
    final minOrderCtrl = TextEditingController(
      text: store?.minOrder.toString() ?? '50000',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.large),
          ),
          title: Text(
            isEdit ? 'Edit Toko' : 'Tambah Toko Baru',
            style: const TextStyle(fontFamily: DesignText.family),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Nama Toko', nameCtrl),
                  _buildTextField('Pemilik', ownerCtrl),
                  _buildTextField('Alamat', addressCtrl),
                  const SizedBox(height: 12),
                  // Info lokasi
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
                                ctx,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerPage(
                                    initialLat: selectedLat,
                                    initialLng: selectedLng,
                                  ),
                                ),
                              );
                              if (result != null) {
                                setDialogState(() {
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
                  _buildTextField('Telepon', phoneCtrl),
                  _buildTextField('WhatsApp', whatsappCtrl),
                  _buildTextField('Email', emailCtrl),
                  _buildTextField('Radius Pengiriman (km)', deliveryRadiusCtrl),
                  _buildTextField('Radius Gratis (km)', freeDeliveryRadiusCtrl),
                  _buildTextField('Biaya per KM (Rp)', costPerKmCtrl),
                  _buildTextField('Min Order (Rp)', minOrderCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  // Generate ID untuk toko baru
                  final storeId =
                      store?.id ??
                      '${DateTime.now().millisecondsSinceEpoch}-${nameCtrl.text.hashCode}';

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
                    deliveryRadius: double.parse(deliveryRadiusCtrl.text),
                    freeDeliveryRadius: double.parse(
                      freeDeliveryRadiusCtrl.text,
                    ),
                    deliveryCostPerKm: int.parse(costPerKmCtrl.text),
                    minOrder: int.parse(minOrderCtrl.text),
                    isActive: true,
                    createdAt: store?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  if (isEdit) {
                    await _repository.updateStore(store.id, newStore);
                  } else {
                    final result = await _repository.addStore(newStore);
                    if (result == null) {
                      throw Exception('Gagal menambah toko ke database');
                    }
                  }

                  if (mounted) {
                    Navigator.pop(ctx);
                    _loadStores();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Toko diupdate' : 'Toko ditambah',
                        ),
                        backgroundColor: DesignColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: DesignColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Toko Delivery'),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stores.isEmpty
          ? const Center(child: Text('Belum ada toko'))
          : ListView.builder(
              itemCount: _stores.length,
              itemBuilder: (context, index) {
                final store = _stores[index];
                return ListTile(
                  title: Text(store.name),
                  subtitle: Text(store.address),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _showAddStoreDialog(store: store),
                      ),
                      PopupMenuItem(
                        child: const Text('Hapus'),
                        onTap: () async {
                          await _repository.deleteStore(store.id);
                          _loadStores();
                          if (Get.isRegistered<DeliveryCheckerController>()) {
                            Get.find<DeliveryCheckerController>()
                                .refreshStores();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStoreDialog(),
        backgroundColor: DesignColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
