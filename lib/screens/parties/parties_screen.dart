import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import 'add_party_screen.dart';
import 'party_detail_screen.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({Key? key}) : super(key: key);

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => Provider.of<PartyProvider>(context, listen: false).loadParties());
  }

  @override
  Widget build(BuildContext context) {
    final partyProv = Provider.of<PartyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties (Khata Book)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: "CUSTOMERS (${partyProv.customers.length})"),
            Tab(text: "SUPPLIERS (${partyProv.suppliers.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Vyapar Top Balance Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.saleGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.saleGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("To Receive (Lena)", style: TextStyle(fontSize: 11, color: AppColors.saleGreen, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(partyProv.totalReceivable),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.saleGreen),
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
                      color: AppColors.dueRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.dueRed.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("To Pay (Dena)", style: TextStyle(fontSize: 11, color: AppColors.dueRed, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(partyProv.totalPayable),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.dueRed),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => partyProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search customer or supplier...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPartyList(partyProv.customers, 'customer'),
                _buildPartyList(partyProv.suppliers, 'supplier'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: Text(_tabController.index == 0 ? "Add Customer" : "Add Supplier"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPartyScreen(
                initialType: _tabController.index == 0 ? 'customer' : 'supplier',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartyList(List parties, String type) {
    if (parties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text("No ${type}s added yet!", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: parties.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final p = parties[i];
        final isReceivable = p.currentBalance >= 0;
        return ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(p.phone.isNotEmpty ? p.phone : 'No phone', style: const TextStyle(fontSize: 12)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatCurrency(p.currentBalance.abs()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isReceivable ? AppColors.saleGreen : AppColors.dueRed,
                ),
              ),
              Text(
                isReceivable ? "To Receive" : "To Pay",
                style: TextStyle(fontSize: 10, color: isReceivable ? AppColors.saleGreen : AppColors.dueRed),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PartyDetailScreen(party: p)),
            );
          },
        );
      },
    );
  }
}
