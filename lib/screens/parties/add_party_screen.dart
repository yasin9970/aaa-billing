import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/party_provider.dart';
import '../../utils/colors.dart';

class AddPartyScreen extends StatefulWidget {
  final String initialType;
  const AddPartyScreen({Key? key, this.initialType = 'customer'}) : super(key: key);

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _balanceController = TextEditingController();

  late String _partyType;
  bool _isReceivable = true; // true = To Receive, false = To Pay

  @override
  void initState() {
    super.initState();
    _partyType = widget.initialType;
    _isReceivable = _partyType == 'customer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_partyType == 'customer' ? 'Add New Customer' : 'Add New Supplier'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Party Type Switcher
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Customer')),
                      selected: _partyType == 'customer',
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      onSelected: (val) {
                        setState(() {
                          _partyType = 'customer';
                          _isReceivable = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Supplier')),
                      selected: _partyType == 'supplier',
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      onSelected: (val) {
                        setState(() {
                          _partyType = 'supplier';
                          _isReceivable = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Party / Business Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter party name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),

              // Opening Balance Box
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Opening Balance (Purana Udhaar)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          labelText: 'Opening Amount',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('To Receive (Lena hai)', style: TextStyle(fontSize: 12)),
                              value: true,
                              groupValue: _isReceivable,
                              activeColor: AppColors.saleGreen,
                              onChanged: (v) => setState(() => _isReceivable = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('To Pay (Dena hai)', style: TextStyle(fontSize: 12)),
                              value: false,
                              groupValue: _isReceivable,
                              activeColor: AppColors.dueRed,
                              onChanged: (v) => setState(() => _isReceivable = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('SAVE PARTY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      double opening = double.tryParse(_balanceController.text.trim()) ?? 0.0;
                      await Provider.of<PartyProvider>(context, listen: false).addParty(
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        type: _partyType,
                        openingBalance: opening,
                        isReceivable: _isReceivable,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
