import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
        actions: [
          // ✅ ICON TOGGLE TEMA DI APPBAR
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: controller.toggleTheme,
              tooltip: controller.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            ),
          ),

          // Edit/Save Button
          Obx(
            () => controller.isEditing.value
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.toggleEdit,
                        tooltip: 'Batal',
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: controller.updateProfile,
                        tooltip: 'Simpan',
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: controller.toggleEdit,
                    tooltip: 'Edit Profil',
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final profile = controller.profile;

        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Obx(
                    () => CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xFFFE8C00),
                      child: controller.isUploadingAvatar.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
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
                                errorBuilder: (context, error, stackTrace) {
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
                    child: GestureDetector(
                      onTap: controller.showAvatarPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE8C00),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF121212)
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
                ],
              ),

              const SizedBox(height: 16),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: controller.isAdmin
                      ? Colors.red.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.isAdmin ? Colors.red : Colors.blue,
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
                      color: controller.isAdmin ? Colors.red : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isAdmin ? 'Administrator' : 'User',
                      style: TextStyle(
                        color: controller.isAdmin ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Email (read-only)
              TextField(
                controller: controller.emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Full Name
              Obx(
                () => TextField(
                  controller: controller.fullNameController,
                  enabled: controller.isEditing.value,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(
                      Icons.person,
                      color: controller.isEditing.value
                          ? const Color(0xFFFE8C00)
                          : Colors.grey,
                    ),
                    filled: true,
                    fillColor: controller.isEditing.value
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFE8C00),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Phone
              Obx(
                () => TextField(
                  controller: controller.phoneController,
                  enabled: controller.isEditing.value,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'No. Telepon',
                    prefixIcon: Icon(
                      Icons.phone,
                      color: controller.isEditing.value
                          ? const Color(0xFFFE8C00)
                          : Colors.grey,
                    ),
                    filled: true,
                    fillColor: controller.isEditing.value
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFE8C00),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFE8C00),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
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

              // Admin Panel Button
              if (controller.isAdmin) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/admin/products'),
                    icon: const Icon(Icons.dashboard),
                    label: const Text(
                      'Kelola Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFE8C00)),
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
}
