import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/party_provider.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class PartyDetailScreen extends StatelessWidget {
  final Party party;
  const PartyDetailScreen({Key? key, required this.party}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReceivable = party.currentBalance >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Party?'),
                  content: Text('Are you sure you want to delete ${party.name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.dueRed),
                      onPressed: () async {
                        await Provider.of<PartyProvider>(context, listen: false).deleteParty(party.id!);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      party.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: party.type == 'customer' ? AppColors.primary.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        party.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: party.type == 'customer' ? AppColors.primary : Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (party.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(party.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                if (party.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(party.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Net Balance", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(party.currentBalance.abs()),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isReceivable ? AppColors.saleGreen : AppColors.dueRed,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isReceivable ? "You'll Receive" : "You'll Pay",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isReceivable ? AppColors.saleGreen : AppColors.dueRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Ledger Entries header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("TRANSACTIONS / LEDGER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReceivable ? AppColors.saleGreen.withOpacity(0.1) : AppColors.dueRed.withOpacity(0.1),
                      child: Icon(
                        isReceivable ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isReceivable ? AppColors.saleGreen : AppColors.dueRed,
                        size: 18,
                      ),
                    ),
                    title: const Text("Opening Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(AppFormatters.formatDate(DateTime.tryParse(party.createdAt) ?? DateTime.now())),
                    trailing: Text(
                      AppFormatters.formatCurrency(party.openingBalance.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isReceivable ? AppColors.saleGreen : AppColors.dueRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
