import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../theme/design_system.dart';
import '../../admin/views/edit_delivery_store_page.dart';
import 'package:cake_by_mommy/app/data/models/delivery_store_model.dart';
import 'package:cake_by_mommy/data/models/store.dart';
import 'package:cake_by_mommy/app/data/repositories/delivery_store_repository.dart';
import 'package:cake_by_mommy/app/modules/delivery_checker/controllers/delivery_checker_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkMode;

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () => controller.refreshProfile(showLoading: false),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: const Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontFamily: DesignText.family,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          DesignColors.primary,
                          DesignColors.darkPrimary,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // PERBAIKAN: Ganti withOpacity -> withValues
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: controller.toggleTheme,
                      tooltip: controller.isDarkMode
                          ? 'Mode Terang'
                          : 'Mode Gelap',
                    ),
                  ),

                  Obx(
                    () => controller.isEditing.value
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: controller.toggleEdit,
                                tooltip: 'Batal',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                onPressed: controller.updateProfile,
                                tooltip: 'Simpan',
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: controller.toggleEdit,
                            tooltip: 'Edit Profil',
                          ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: DesignColors.primary,
                        ),
                      ),
                    );
                  }
                  final profile = controller.profile;
                  if (profile == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Data profil tidak ditemukan'),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Obx(
                              () => CircleAvatar(
                                radius: 70,
                                backgroundColor: DesignColors.primary,
                                child: controller.isUploadingAvatar.value
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      )
                                    : profile.avatarUrl != null &&
                                          profile.avatarUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          profile.avatarUrl!,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 70,
                                                  color: Colors.white,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                              ),
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: SizedBox(
                                width: 46,
                                height: 46,
                                child: _AnimatedButton(
                                  onTap: controller.showAvatarPicker,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: DesignColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF1B1B1B)
                                            : Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isAdmin
                                ? (isDark
                                      ? DesignColors.error.withValues(
                                          alpha: 0.12,
                                        )
                                      : DesignColors.error.withValues(
                                          alpha: 0.06,
                                        ))
                                : (isDark
                                      ? DesignColors.info.withValues(
                                          alpha: 0.10,
                                        )
                                      : DesignColors.info.withValues(
                                          alpha: 0.08,
                                        )),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: controller.isAdmin
                                  ? DesignColors.error
                                  : DesignColors.info,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: controller.isAdmin
                                    ? DesignColors.error
                                    : DesignColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(''),
                              Text(
                                controller.isAdmin ? 'Administrator' : 'User',
                                style: TextStyle(
                                  fontFamily: DesignText.family,
                                  color: controller.isAdmin
                                      ? DesignColors.error
                                      : (isDark ? Colors.white : Colors.black),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        const SizedBox(height: 8),

                        Obx(
                          () => TextField(
                            key: ValueKey(controller.emailText.value),
                            controller: controller.emailController,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(
                          () => TextField(
                            key: ValueKey(controller.fullNameText.value),
                            controller: controller.fullNameController,
                            enabled: controller.isEditing.value,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: Icon(
                                Icons.person,
                                color: controller.isEditing.value
                                    ? DesignColors.primary
                                    : Colors.grey,
                              ),
                              filled: true,
                              fillColor: controller.isEditing.value
                                  ? (isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white)
                                  : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: DesignColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(
                          () => TextField(
                            key: ValueKey(controller.phoneText.value),
                            controller: controller.phoneController,
                            enabled: controller.isEditing.value,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'No. Telepon',
                              prefixIcon: Icon(
                                Icons.phone,
                                color: controller.isEditing.value
                                    ? DesignColors.primary
                                    : Colors.grey,
                              ),
                              filled: true,
                              fillColor: controller.isEditing.value
                                  ? (isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white)
                                  : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: DesignColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : DesignColors.lightPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: DesignColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Informasi Akun',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                icon: Icons.calendar_today,
                                label: 'Bergabung sejak',
                                value: _formatDate(profile.createdAt),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.update,
                                label: 'Terakhir diperbarui',
                                value: _formatDate(profile.updatedAt),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (controller.isAdmin) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _AnimatedButton(
                              onTap: () async {
                                final repo = DeliveryStoreRepository();
                                final stores = await repo.getAllStores();
                                final deliveryStore = stores.isNotEmpty
                                    ? stores.first
                                    : null;
                                final result = await Get.to(
                                  () => EditDeliveryStorePage(
                                    store: deliveryStore,
                                  ),
                                );
                                if (result == true) {
                                  if (Get.isRegistered<
                                    DeliveryCheckerController
                                  >()) {
                                    Get.find<DeliveryCheckerController>()
                                        .fetchStore();
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: DesignColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      // PERBAIKAN: Ganti withOpacity -> withValues
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.store, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Kelola Toko Delivery',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _AnimatedButton(
                              onTap: () => Get.toNamed('/admin/products'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: DesignColors.darkPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      // PERBAIKAN: Ganti withOpacity -> withValues
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.dashboard, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Kelola Produk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: _AnimatedButton(
                            onTap: controller.logout,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: DesignColors.error,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: DesignColors.error),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontFamily: DesignText.family,
                                      color: Color(0xFFE74C3C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DesignColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  DeliveryStore? storeToDeliveryStore(Store? s) {
    if (s == null) return null;
    return DeliveryStore(
      id: s.id,
      name: s.name,
      owner: s.owner,
      address: s.address,
      latitude: s.latitude,
      longitude: s.longitude,
      phone: s.phone,
      whatsapp: s.whatsapp,
      email: s.email,
      deliveryRadius: s.deliveryRadius,
      freeDeliveryRadius: s.freeDeliveryRadius,
      deliveryCostPerKm: s.deliveryCostPerKm,
      minOrder: s.minOrder,
      isActive: s.isActive,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _AnimatedButton({required this.onTap, required this.child});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) async {
    setState(() => _pressed = false);
    await Future.delayed(const Duration(milliseconds: 60));
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _pressed ? 0.95 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
