import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import 'add_item_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ItemProvider>(context, listen: false).loadItems());
  }

  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items & Inventory (Stock)'),
      ),
      body: Column(
        children: [
          // Top Vyapar Inventory Summary Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Products", style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          "${itemProv.totalItemCount} Items",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: itemProv.lowStockCount > 0 ? AppColors.warningOrange.withOpacity(0.08) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: itemProv.lowStockCount > 0 ? AppColors.warningOrange.withOpacity(0.3) : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Low Stock Alert",
                          style: TextStyle(
                            fontSize: 11,
                            color: itemProv.lowStockCount > 0 ? AppColors.warningOrange : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${itemProv.lowStockCount} Items",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: itemProv.lowStockCount > 0 ? AppColors.warningOrange : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => itemProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search product or category...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: itemProv.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text("No products in inventory yet!", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: itemProv.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = itemProv.items[i];
                      final isLow = item.currentStock <= item.minStockAlert;

                      return ListTile(
                        tileColor: Colors.white,
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          "Sale: ${AppFormatters.formatCurrency(item.salePrice)}  •  ${item.category}",
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${item.currentStock.toStringAsFixed(0)} ${item.unit}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isLow ? AppColors.dueRed : AppColors.saleGreen,
                              ),
                            ),
                            if (isLow)
                              const Text(
                                "Low Stock",
                                style: TextStyle(fontSize: 10, color: AppColors.dueRed, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Delete Product?'),
                              content: Text('Remove ${item.name} from inventory?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.dueRed),
                                  onPressed: () async {
                                    await itemProv.deleteItem(item.id!);
                                    Navigator.pop(dialogCtx);
                                  },
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
      ),
    );
  }
}
