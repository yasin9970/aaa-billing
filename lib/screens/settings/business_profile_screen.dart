import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/business_provider.dart';
import '../../utils/colors.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _termsCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<BusinessProvider>(context, listen: false).profile;
    _nameCtrl = TextEditingController(text: p.businessName);
    _phoneCtrl = TextEditingController(text: p.phone);
    _addressCtrl = TextEditingController(text: p.address);
    _emailCtrl = TextEditingController(text: p.email);
    _termsCtrl = TextEditingController(text: p.terms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop / Business Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Shop / Business Name *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.store)),
                validator: (v) => v == null || v.trim().isEmpty ? "Shop name cannot be empty" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Business Phone Number *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (v) => v == null || v.trim().isEmpty ? "Phone cannot be empty" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Full Address", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _termsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Terms & Conditions on Bill", border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text("SAVE BUSINESS DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updated = BusinessProfile(
                        businessName: _nameCtrl.text.trim(),
                        phone: _phoneCtrl.text.trim(),
                        address: _addressCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                        terms: _termsCtrl.text.trim(),
                      );
                      await Provider.of<BusinessProvider>(context, listen: false).updateProfile(updated);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Business Profile Updated Successfully!")));
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
