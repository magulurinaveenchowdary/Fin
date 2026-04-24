import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finval/providers/subscription_provider.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:uuid/uuid.dart';
import 'package:finval/data/models/subscription.dart';
import 'package:intl/intl.dart';

// Popular services with icon data
const _popularServices = [
  {'name': 'Netflix', 'icon': Icons.play_circle_fill},
  {'name': 'Amazon Prime', 'icon': Icons.local_shipping},
  {'name': 'Spotify', 'icon': Icons.music_note},
  {'name': 'YouTube Premium', 'icon': Icons.smart_display},
  {'name': 'Disney+ Hotstar', 'icon': Icons.star},
  {'name': 'Apple Music', 'icon': Icons.apple},
  {'name': 'Zee5', 'icon': Icons.live_tv},
  {'name': 'SonyLiv', 'icon': Icons.tv},
  {'name': 'Other', 'icon': Icons.apps},
];

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionProvider);
    final totalMonthly = ref.read(subscriptionProvider.notifier).totalMonthlyCost;
    final totalAnnual = totalMonthly * 12;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubscriptionSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.subscriptions, color: AppColors.info, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Cost', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                    Text('₹${NumberFormat('#,##,###.##').format(totalMonthly)}',
                        style: AppTextStyles.h2.copyWith(color: AppColors.info)),
                    Text('₹${NumberFormat('#,##,###').format(totalAnnual.ceil())} / year',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: subscriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.subscriptions_outlined, size: 72, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text('No subscriptions yet', style: AppTextStyles.h3.copyWith(color: AppColors.grey500)),
                        const SizedBox(height: 8),
                        Text('Tap + to track your subscriptions', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) => _buildTile(context, ref, subscriptions[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, Subscription sub) {
    return Dismissible(
      key: Key(sub.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Subscription'),
            content: Text('Remove "${sub.name}" from subscriptions?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => ref.read(subscriptionProvider.notifier).deleteSubscription(sub.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: AppColors.info.withOpacity(0.12),
            child: Icon(_getServiceIcon(sub.name), color: AppColors.info, size: 22),
          ),
          title: Text(sub.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${sub.cycle.name[0].toUpperCase()}${sub.cycle.name.substring(1)} • Bills on day ${sub.billingDay}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${NumberFormat('#,##,###').format(sub.amount)}',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.info)),
              Text(sub.category, style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.grey500)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) return Icons.play_circle_fill;
    if (lower.contains('spotify')) return Icons.music_note;
    if (lower.contains('amazon')) return Icons.local_shipping;
    if (lower.contains('youtube')) return Icons.smart_display;
    if (lower.contains('apple')) return Icons.apple;
    return Icons.stars;
  }

  void _showAddSubscriptionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AddSubscriptionSheet(ref: ref),
    );
  }
}

class _AddSubscriptionSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddSubscriptionSheet({required this.ref});

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  BillingCycle _selectedCycle = BillingCycle.monthly;
  int _billingDay = 1;
  String _selectedCategory = 'Entertainment';

  final _categories = ['Entertainment', 'Productivity', 'Health', 'Education', 'News', 'Music', 'Cloud', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
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
                Text('Add Subscription', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            // Popular quick-picks
            Text('Popular Services', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularServices.map((s) {
                  return GestureDetector(
                    onTap: () => setState(() => _nameController.text = s['name'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.info.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s['icon'] as IconData, size: 14, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text(s['name'] as String, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Service Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<BillingCycle>(
                    value: _selectedCycle,
                    decoration: InputDecoration(labelText: 'Cycle', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: BillingCycle.values.map((c) => DropdownMenuItem(value: c, child: Text('${c.name[0].toUpperCase()}${c.name.substring(1)}'))).toList(),
                    onChanged: (val) => setState(() => _selectedCycle = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _billingDay,
                    decoration: InputDecoration(labelText: 'Bill Day', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (val) => setState(() => _billingDay = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter service name and amount')),
                    );
                    return;
                  }
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }
                  widget.ref.read(subscriptionProvider.notifier).addSubscription(Subscription(
                    id: const Uuid().v4(),
                    name: _nameController.text.trim(),
                    iconKey: 'default',
                    amount: amount,
                    cycle: _selectedCycle,
                    billingDay: _billingDay,
                    startDate: DateTime.now(),
                    category: _selectedCategory,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Add Subscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
