import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finval/providers/settings_provider.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:finval/data/models/salary_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryConfig = ref.watch(settingsProvider);
    final modules = ref.watch(appModulesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.h2)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Module Toggles ────────────────────────────────────────────────
          _sectionHeader(context, 'App Modules',
              'Enable / disable features. Off → removed from home & navigation.'),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _moduleToggle(
                  context,
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  title: 'Transactions / Ledger',
                  subtitle: 'Full transaction history, filters & delete',
                  value: modules.transactions,
                  onChanged: (v) =>
                      ref.read(appModulesProvider.notifier).toggleTransactions(v),
                ),
                _divider(),
                _moduleToggle(
                  context,
                  icon: Icons.account_balance_outlined,
                  color: AppColors.accent,
                  title: 'EMI Manager',
                  subtitle: 'Track loans, mark instalments paid',
                  value: modules.emi,
                  onChanged: (v) =>
                      ref.read(appModulesProvider.notifier).toggleEMI(v),
                ),
                _divider(),
                _moduleToggle(
                  context,
                  icon: Icons.subscriptions_outlined,
                  color: AppColors.info,
                  title: 'Subscriptions',
                  subtitle: 'Track recurring services like Netflix, Spotify',
                  value: modules.subscriptions,
                  onChanged: (v) =>
                      ref.read(appModulesProvider.notifier).toggleSubscriptions(v),
                ),
                _divider(),
                _moduleToggle(
                  context,
                  icon: Icons.people_outline,
                  color: const Color(0xFF9B59B6),
                  title: 'Debts & Lending',
                  subtitle: 'Who owes whom, WhatsApp reminders',
                  value: modules.debts,
                  onChanged: (v) =>
                      ref.read(appModulesProvider.notifier).toggleDebts(v),
                ),
                _divider(),
                _moduleToggle(
                  context,
                  icon: Icons.bar_chart_outlined,
                  color: AppColors.grey700,
                  title: 'Analytics & Stats',
                  subtitle: 'Charts, category breakdown, trends',
                  value: modules.analytics,
                  onChanged: (v) =>
                      ref.read(appModulesProvider.notifier).toggleAnalytics(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Salary / Financial Setup ──────────────────────────────────────
          _sectionHeader(context, 'Financial Setup', null),
          const SizedBox(height: 12),
          _buildSalaryCard(context, ref, salaryConfig),

          const SizedBox(height: 28),

          // ── Preferences ───────────────────────────────────────────────────
          _sectionHeader(context, 'Preferences', null),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Theme Mode'),
                  trailing: const Text('System', style: TextStyle(color: AppColors.grey600)),
                  onTap: () {},
                ),
                _divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification Preferences'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                  onTap: () {},
                ),
                _divider(),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Biometric Lock'),
                  trailing: Switch(value: false, onChanged: (val) {}),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Data ─────────────────────────────────────────────────────────
          _sectionHeader(context, 'Data Management', null),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup Data'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                  onTap: () {},
                ),
                _divider(),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: const Text('Restore Data'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Center(
            child: Text('FinVault v1.0.0',
                style: TextStyle(color: AppColors.grey400, fontSize: 12)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
        ],
      ],
    );
  }

  Widget _moduleToggle(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value ? color.withValues(alpha: 0.12) : AppColors.grey200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: value ? color : AppColors.grey500, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: value ? null : AppColors.grey500,
        ),
      ),
      subtitle: Text(subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
      trailing: Switch(
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 72);

  Widget _buildSalaryCard(
      BuildContext context, WidgetRef ref, SalaryConfig config) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Salary',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      config.isEnabled
                          ? 'Auto-credits on day ${config.creditDay}'
                          : 'Auto-credit disabled',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showSalaryEditDialog(context, ref, config),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${config.amount.toStringAsFixed(0)}',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalaryEditDialog(
      BuildContext context, WidgetRef ref, SalaryConfig config) {
    final amountController =
        TextEditingController(text: config.amount.toStringAsFixed(0));
    final dayController =
        TextEditingController(text: config.creditDay.toString());
    bool isEnabled = config.isEnabled;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Salary Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Monthly Amount', prefixText: '₹ '),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Credit Day (1–28)'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enable Auto-credit'),
                value: isEnabled,
                onChanged: (val) =>
                    setDialogState(() => isEnabled = val),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final day = int.tryParse(dayController.text);
                if (amount == null || amount <= 0 || day == null) return;
                ref.read(settingsProvider.notifier).updateSalaryConfig(
                      SalaryConfig(
                        isEnabled: isEnabled,
                        amount: amount,
                        creditDay: day.clamp(1, 28),
                        currency: 'INR',
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
