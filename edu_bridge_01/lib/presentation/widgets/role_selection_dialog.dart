import 'package:flutter/material.dart';

class RoleSelectionDialog extends StatelessWidget {
  final Function(String) onRoleSelected;

  const RoleSelectionDialog({
    super.key,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.125, // 12.5% margin on each side = 75% width
        vertical: MediaQuery.of(context).size.height * 0.175,  // 17.5% margin top/bottom = 65% height
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Your Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please select your role to complete the sign-up process.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildRoleButton(context, 'Student', Icons.school),
            const SizedBox(height: 12),
            _buildRoleButton(context, 'Teacher', Icons.person_outline),
            const SizedBox(height: 12),
            _buildRoleButton(context, 'Parent', Icons.family_restroom),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          onRoleSelected(role);
        },
        icon: Icon(icon),
        label: Text(role),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
