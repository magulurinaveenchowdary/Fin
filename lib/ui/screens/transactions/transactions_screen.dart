import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finval/providers/transaction_provider.dart';
import 'package:finval/data/models/transaction.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:finval/ui/widgets/common/add_transaction_sheet.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'All'; // All, Income, Expense
  String _sortBy = 'Date'; // Date, Amount

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsProvider);
    final txnNotifier = ref.read(transactionsProvider.notifier);

    var filtered = allTransactions.where((t) {
      if (_filter == 'Income') return t.type == TransactionType.income;
      if (_filter == 'Expense') return t.type == TransactionType.expense;
      return true;
    }).toList();

    if (_sortBy == 'Amount') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: AppTextStyles.h2),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'Amount', child: Text('Sort by Amount')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips + summary row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _filterChip('All', Icons.list_alt),
                const SizedBox(width: 8),
                _filterChip('Income', Icons.arrow_downward_rounded),
                const SizedBox(width: 8),
                _filterChip('Expense', Icons.arrow_upward_rounded),
              ],
            ),
          ),

          // Balance summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _statBubble('Income', txnNotifier.totalIncome, AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _statBubble('Expense', txnNotifier.totalExpense, AppColors.danger)),
                const SizedBox(width: 8),
                Expanded(child: _statBubble('Balance', txnNotifier.balance, txnNotifier.balance >= 0 ? AppColors.primary : AppColors.danger)),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey300),
                        const SizedBox(height: 12),
                        Text('No transactions', style: AppTextStyles.h3.copyWith(color: AppColors.grey500)),
                        const SizedBox(height: 8),
                        Text(
                          _filter == 'All' ? 'Tap + to add your first one' : 'No $_filter transactions',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final txn = filtered[index];
                      return _buildTile(context, txn);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'income',
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            onPressed: () => showAddTransactionSheet(context, TransactionType.income),
            child: const Icon(Icons.arrow_downward_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'expense',
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            onPressed: () => showAddTransactionSheet(context, TransactionType.expense),
            icon: const Icon(Icons.add),
            label: const Text('Expense'),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    final selected = _filter == label;
    Color color = label == 'Income' ? AppColors.success : label == 'Expense' ? AppColors.danger : AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(selected ? 0 : 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _statBubble(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text('₹${NumberFormat('#,##,###').format(value.abs())}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, Transaction txn) {
    final isIncome = txn.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.danger;

    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.danger,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
          ],
        ),
      ),
      onDismissed: (_) => ref.read(transactionsProvider.notifier).deleteTransaction(txn.id),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 18),
        ),
        title: Text(txn.categoryId, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          txn.note?.isNotEmpty == true ? '${txn.note} • ${DateFormat('dd MMM yy').format(txn.date)}' : DateFormat('dd MMM yyyy').format(txn.date),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}₹${NumberFormat('#,##,###').format(txn.amount)}',
          style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
