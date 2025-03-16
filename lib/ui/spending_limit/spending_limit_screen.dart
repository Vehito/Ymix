import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/managers.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/spending_limit.dart';
import 'package:ymix/ui/shared/format_helper.dart';

class SpendingLimitScreen extends StatefulWidget {
  const SpendingLimitScreen({super.key});

  @override
  State<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends State<SpendingLimitScreen> {
  @override
  Widget build(BuildContext context) {
    final spendingLimitManager = context.watch<SpendingLimitManager>();
    final categoryManager = context.read<CategoryManager>();
    late final Set<Category> categories;

    Future<void> getCategories() async {
      await categoryManager.init();
      categories = categoryManager.categories;
    }

    Future<List<SpendingLimit>> getLimitList() async {
      spendingLimitManager.init();
      return spendingLimitManager.spendingLimitList;
    }

    Category getCategory(String id) {
      return categories.firstWhere((ca) => ca.id == id);
    }

    return FutureBuilder(
        future: getLimitList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu!"));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No Spending Limit"));
          } else {
            return ListView.separated(
                itemBuilder: (context, index) => _buildCard(
                      getCategory(snapshot.data![index].categoryId),
                      snapshot.data![index],
                    ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: snapshot.data!.length);
          }
        });
  }

  Widget _buildCard(Category category, SpendingLimit limit) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bar_chart),
        title: Row(
          children: [
            const Text('Category: '),
            Icon(category.icon, color: category.color),
            Text(category.name)
          ],
        ),
        subtitle: Column(
          children: [
            Text(
                'Current: ${FormatHelper.numberFormat.format(limit.currentSpending)}${limit.currencySymbol}'),
            Text(
                'Amount:  ${FormatHelper.numberFormat.format(limit.amount)}${limit.currencySymbol}'),
            Text(
                'From: ${FormatHelper.dateFormat.format(limit.start)} - To: ${FormatHelper.dateFormat.format(limit.end)}'),
          ],
        ),
      ),
    );
  }
}
