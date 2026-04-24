import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finval/providers/transaction_provider.dart';
import 'package:finval/providers/emi_provider.dart';
import 'package:finval/providers/subscription_provider.dart';
import 'package:finval/providers/settings_provider.dart';
import 'package:finval/data/models/transaction.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:finval/ui/widgets/common/add_transaction_sheet.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final txnNotifier = ref.read(transactionsProvider.notifier);
    final emiNotifier = ref.read(emiProvider.notifier);
    final subNotifier = ref.read(subscriptionProvider.notifier);
    final modules = ref.watch(appModulesProvider);

    final balance = txnNotifier.balance;
    final totalIncome = txnNotifier.totalIncome;
    final totalExpense = txnNotifier.totalExpense;
    final totalEMI = emiNotifier.totalMonthlyEMIAmount;
    final totalSubs = subNotifier.totalMonthlyCost;

    final recentTxns = transactions.take(5).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF003D3D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FinVault',
                            style: AppTextStyles.h2.copyWith(
                                color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${NumberFormat('#,##,###.##').format(balance)}',
                          style: AppTextStyles.h1.copyWith(
                              color: Colors.white, fontSize: 38, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text('Net Balance',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white54)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _miniStat('Income', totalIncome, AppColors.success),
                            const SizedBox(width: 24),
                            _miniStat('Expenses', totalExpense,
                                const Color(0xFFFF6B6B)),
                            if (modules.emi) ...[
                              const SizedBox(width: 24),
                              _miniStat('EMIs', totalEMI, AppColors.accent),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Quick Actions (module-aware) ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // Always visible
                      _quickAction(
                        context, Icons.add_circle_outline, 'Income',
                        AppColors.success,
                        () => showAddTransactionSheet(
                            context, TransactionType.income),
                      ),
                      _quickAction(
                        context, Icons.remove_circle_outline, 'Expense',
                        AppColors.danger,
                        () => showAddTransactionSheet(
                            context, TransactionType.expense),
                      ),
                      if (modules.emi)
                        _quickAction(
                          context, Icons.account_balance_outlined, 'EMI',
                          AppColors.accent,
                          () => context.go('/emi'),
                        ),
                      if (modules.subscriptions)
                        _quickAction(
                          context, Icons.subscriptions_outlined, 'Subs',
                          AppColors.info,
                          () => context.go('/subscriptions'),
                        ),
                      if (modules.debts)
                        _quickAction(
                          context, Icons.people_outline, 'Debts',
                          const Color(0xFF9B59B6),
                          () => context.go('/debts'),
                        ),
                      if (modules.analytics)
                        _quickAction(
                          context, Icons.bar_chart_outlined, 'Stats',
                          AppColors.grey700,
                          () => context.go('/analytics'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Monthly Summary Cards (module-aware) ─────────────────────────
          if (modules.emi || modules.subscriptions)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (modules.subscriptions)
                          Expanded(
                            child: _summaryCard(
                              'Subscriptions',
                              '₹${totalSubs.toStringAsFixed(0)}',
                              Icons.subscriptions,
                              AppColors.info,
                            ),
                          ),
                        if (modules.subscriptions && modules.emi)
                          const SizedBox(width: 12),
                        if (modules.emi)
                          Expanded(
                            child: _summaryCard(
                              'EMI Burden',
                              '₹${totalEMI.toStringAsFixed(0)}',
                              Icons.account_balance,
                              AppColors.accent,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── Recent Transactions header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: AppTextStyles.h3),
                  if (modules.transactions)
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text('View All'),
                    ),
                  if (modules.analytics && !modules.transactions)
                    TextButton(
                      onPressed: () => context.go('/analytics'),
                      child: const Text('View Stats'),
                    ),
                ],
              ),
            ),
          ),

          // ── Transactions list ─────────────────────────────────────────────
          if (recentTxns.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 56, color: AppColors.grey300),
                    const SizedBox(height: 12),
                    Text('No transactions yet',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.grey500)),
                    const SizedBox(height: 4),
                    Text('Tap + to add your first entry',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey400)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final txn = recentTxns[index];
                  final isIncome = txn.type == TransactionType.income;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: (isIncome
                              ? AppColors.success
                              : AppColors.danger)
                          .withValues(alpha: 0.12),
                      child: Icon(
                        isIncome
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isIncome ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                    ),
                    title: Text(txn.categoryId,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      txn.note?.isNotEmpty == true
                          ? '${txn.note} • ${DateFormat('dd MMM').format(txn.date)}'
                          : DateFormat('dd MMM yyyy').format(txn.date),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey500),
                    ),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}₹${NumberFormat('#,##,###').format(txn.amount)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isIncome ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                childCount: recentTxns.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showAddTransactionSheet(context, TransactionType.expense),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(
          '₹${NumberFormat('#,##,###').format(value)}',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.label.copyWith(color: color)),
              Text(value,
                  style: AppTextStyles.h3.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
