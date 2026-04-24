import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finval/providers/emi_provider.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:finval/core/utils/emi_calculator.dart';
import 'package:uuid/uuid.dart';
import 'package:finval/data/models/emi.dart';
import 'package:intl/intl.dart';

class EMIScreen extends ConsumerWidget {
  const EMIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emis = ref.watch(emiProvider);
    final totalMonthly = ref.read(emiProvider.notifier).totalMonthlyEMIAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('EMI Manager', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEMISheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFFE67E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Monthly EMI', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    Text(
                      '₹${NumberFormat('#,##,###').format(totalMonthly)}',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    Text('${emis.where((e) => e.isActive).length} active loans', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: emis.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_outlined, size: 72, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text('No active loans', style: AppTextStyles.h3.copyWith(color: AppColors.grey500)),
                        const SizedBox(height: 8),
                        Text('Tap + to add an EMI', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: emis.length,
                    itemBuilder: (context, index) => _buildEMICard(context, ref, emis[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMICard(BuildContext context, WidgetRef ref, EMI emi) {
    final progress = emi.tenureMonths > 0 ? emi.paidMonths.length / emi.tenureMonths : 0.0;
    final remaining = emi.tenureMonths - emi.paidMonths.length;
    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final alreadyPaidThisMonth = emi.paidMonths.contains(monthYear);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emi.loanName, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(emi.lenderName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${NumberFormat('#,##,###').format(emi.emiAmount)}/mo',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem('Principal', '₹${NumberFormat('#,##,###').format(emi.principal)}'),
                _infoItem('Rate', '${emi.interestRate}% p.a.'),
                _infoItem('Remaining', '$remaining months'),
                _infoItem('Total Interest', '₹${NumberFormat('#,##,###').format(EMICalculator.calculateTotalInterest(EMICalculator.calculateTotalPayable(emi.emiAmount, emi.tenureMonths), emi.principal))}'),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.grey200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${emi.paidMonths.length}/${emi.tenureMonths} paid',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
                ),
                if (alreadyPaidThisMonth)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('✓ Paid this month', style: AppTextStyles.label.copyWith(color: AppColors.success)),
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Paid'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: () => ref.read(emiProvider.notifier).markAsPaid(emi.id, monthYear),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.grey500, fontSize: 10)),
        Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showAddEMISheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AddEMISheet(ref: ref),
    );
  }
}

class _AddEMISheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddEMISheet({required this.ref});

  @override
  State<_AddEMISheet> createState() => _AddEMISheetState();
}

class _AddEMISheetState extends State<_AddEMISheet> {
  final _loanNameController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  double _calculatedEMI = 0;

  @override
  void dispose() {
    _loanNameController.dispose();
    _lenderNameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;
    if (principal > 0 && rate > 0 && tenure > 0) {
      setState(() {
        _calculatedEMI = EMICalculator.calculateEMI(principal: principal, annualRate: rate, tenureMonths: tenure);
      });
    }
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
                Text('Add New Loan', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loanNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Loan Name (e.g. Home Loan)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lenderNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Lender (e.g. HDFC Bank)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _principalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _recalculate(),
              decoration: InputDecoration(labelText: 'Principal Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculate(),
                    decoration: InputDecoration(labelText: 'Annual Rate (%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculate(),
                    decoration: InputDecoration(labelText: 'Tenure (months)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
            if (_calculatedEMI > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text('Calculated EMI', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                    Text('₹${NumberFormat('#,##,###.##').format(_calculatedEMI)}/month',
                        style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                    Text('Total: ₹${NumberFormat('#,##,###').format(EMICalculator.calculateTotalPayable(_calculatedEMI, int.tryParse(_tenureController.text) ?? 0))}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (_loanNameController.text.isEmpty || _principalController.text.isEmpty ||
                      _rateController.text.isEmpty || _tenureController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                  final principal = double.parse(_principalController.text);
                  final rate = double.parse(_rateController.text);
                  final tenure = int.parse(_tenureController.text);
                  final emiAmount = EMICalculator.calculateEMI(principal: principal, annualRate: rate, tenureMonths: tenure);

                  widget.ref.read(emiProvider.notifier).addEMI(EMI(
                    id: const Uuid().v4(),
                    loanName: _loanNameController.text.trim(),
                    lenderName: _lenderNameController.text.trim(),
                    principal: principal,
                    interestRate: rate,
                    tenureMonths: tenure,
                    startDate: DateTime.now(),
                    emiAmount: emiAmount,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Add Loan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
