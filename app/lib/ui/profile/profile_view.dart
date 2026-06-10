import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../login/login_viewmodel.dart';
import '../login/login_view.dart';

const List<String> _avatarOptions = [
  '🏸', '⚽', '🏏', '🎾', '🏀', '🏐',
  '⛳', '🏊', '🚴', '🏋️', '🤸', '⛷️',
  '🧗', '🏄', '🤺', '🥊', '🎯', '🏆',
  '😎', '🦁', '🐯', '🦊', '🐻', '🐼',
];

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  String _selectedAvatar = '🏸';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<LoginViewModel>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _bioController.text = user.bio;
      _selectedAvatar = user.avatar;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Your Avatar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _avatarOptions.length,
              itemBuilder: (_, index) {
                final emoji = _avatarOptions[index];
                final isSelected = emoji == _selectedAvatar;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatar = emoji);
                    Navigator.pop(ctx);
                    _saveAvatar(emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAvatar(String emoji) async {
    final vm = context.read<LoginViewModel>();
    final success = await vm.updateProfile(avatar: emoji);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated! ✅')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final vm = context.read<LoginViewModel>();
    final success = await vm.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated! ✅')),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LoginViewModel>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final user = vm.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Edit/Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_isEditing) _loadUserData();
                          setState(() => _isEditing = !_isEditing);
                        },
                      ),
                    ),
                  ),

                  // Avatar
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedAvatar,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fields
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    icon: Icons.person_outlined,
                    label: 'Full Name',
                    controller: _nameController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                    enabled: false,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    icon: Icons.info_outlined,
                    label: 'Bio',
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : _saveProfile,
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade100,
        ),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? value : null,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
