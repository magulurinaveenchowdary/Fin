import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finval/providers/debt_provider.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:uuid/uuid.dart';
import 'package:finval/data/models/debt.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtProvider);
    final netPosition = ref.read(debtProvider.notifier).netDebtPosition;

    final activeDebts = debts.where((d) => !d.isSettled).toList();
    final settledDebts = debts.where((d) => d.isSettled).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Debts & Lending', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddDebtSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Net position banner
          _buildNetPositionBanner(netPosition),

          Expanded(
            child: debts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handshake_outlined, size: 72, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text('No records yet', style: AppTextStyles.h3.copyWith(color: AppColors.grey500)),
                        const SizedBox(height: 8),
                        Text('Tap + to record a debt or lending', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (activeDebts.isNotEmpty) ...[
                        Text('Active (${activeDebts.length})', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        ...activeDebts.map((d) => _buildDebtCard(context, ref, d)),
                      ],
                      if (settledDebts.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Settled (${settledDebts.length})', style: AppTextStyles.h3.copyWith(color: AppColors.grey500)),
                        const SizedBox(height: 12),
                        ...settledDebts.map((d) => _buildDebtCard(context, ref, d)),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetPositionBanner(double netPosition) {
    final isPositive = netPosition >= 0;
    final color = isPositive ? AppColors.success : AppColors.danger;
    final label = isPositive ? '✓ Others owe you' : '⚠ You owe others';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: color, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
              Text(
                '₹${NumberFormat('#,##,###.##').format(netPosition.abs())}',
                style: AppTextStyles.h2.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, WidgetRef ref, Debt debt) {
    final isIOwe = debt.type == DebtType.iOwe;
    final remaining = debt.totalAmount - debt.paidAmount;
    final color = isIOwe ? AppColors.danger : AppColors.success;
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(isIOwe ? Icons.arrow_outward : Icons.south, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.personName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        isIOwe ? 'I owe them' : 'They owe me',
                        style: AppTextStyles.bodySmall.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${NumberFormat('#,##,###').format(debt.totalAmount)}',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (debt.isSettled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('SETTLED', style: AppTextStyles.label.copyWith(color: AppColors.success, fontSize: 9)),
                      )
                    else
                      Text('₹${NumberFormat('#,##,###').format(remaining)} left',
                          style: AppTextStyles.label.copyWith(color: AppColors.danger, fontSize: 10)),
                  ],
                ),
              ],
            ),
            if (debt.purpose != null && debt.purpose!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(debt.purpose!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
            ],
            if (!debt.isSettled) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% repaid',
                style: AppTextStyles.label.copyWith(color: AppColors.grey500, fontSize: 10),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (debt.personPhone != null && debt.personPhone!.isNotEmpty)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.message_outlined, size: 16),
                      label: const Text('Remind'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _sendReminder(debt),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payments_outlined, size: 16),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _showRepayDialog(context, ref, debt),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendReminder(Debt debt) async {
    final amount = debt.totalAmount - debt.paidAmount;
    final message = 'Hi ${debt.personName}! 👋 Just a friendly reminder about ₹${NumberFormat('#,##,###').format(amount)} pending. Please settle when convenient. - Sent via FinVault';
    final phone = debt.personPhone!.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showRepayDialog(BuildContext context, WidgetRef ref, Debt debt) {
    final controller = TextEditingController(text: debt.paidAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: ₹${NumberFormat('#,##,###').format(debt.totalAmount)}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Amount Paid So Far', prefixText: '₹ ', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 0) {
                ref.read(debtProvider.notifier).updateRepayment(debt.id, amount.clamp(0, debt.totalAmount));
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AddDebtSheet(ref: ref),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddDebtSheet({required this.ref});

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  DebtType _type = DebtType.iOwe;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Add Debt Record', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<DebtType>(
              segments: [
                ButtonSegment(value: DebtType.iOwe, label: const Text('I Owe'), icon: const Icon(Icons.arrow_outward, size: 16)),
                ButtonSegment(value: DebtType.theyOwe, label: const Text('They Owe Me'), icon: const Icon(Icons.south, size: 16)),
              ],
              selected: {_type},
              onSelectionChanged: (val) => setState(() => _type = val.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Person Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number (for WhatsApp reminder)',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (₹) *',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                labelText: 'Purpose (e.g. Dinner, Rent)',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == DebtType.iOwe ? AppColors.danger : AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (_nameController.text.trim().isEmpty || _amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill name and amount')),
                    );
                    return;
                  }
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount')),
                    );
                    return;
                  }
                  widget.ref.read(debtProvider.notifier).addDebt(Debt(
                    id: const Uuid().v4(),
                    type: _type,
                    personName: _nameController.text.trim(),
                    personPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                    totalAmount: amount,
                    date: _selectedDate,
                    purpose: _purposeController.text.trim().isEmpty ? null : _purposeController.text.trim(),
                  ));
                  Navigator.pop(context);
                },
                child: Text(
                  _type == DebtType.iOwe ? 'Record: I Owe ₹${_amountController.text.isEmpty ? '0' : _amountController.text}' : 'Record: They Owe ₹${_amountController.text.isEmpty ? '0' : _amountController.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
