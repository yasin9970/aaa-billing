class BusinessProfile {
  final int? id;
  final String businessName;
  final String phone;
  final String address;
  final String email;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String terms;
  final String currencySymbol;

  BusinessProfile({
    this.id,
    required this.businessName,
    required this.phone,
    required this.address,
    this.email = '',
    this.invoicePrefix = 'INV-',
    this.nextInvoiceNumber = 1,
    this.terms = 'Thank you for your business!',
    this.currencySymbol = '₹',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'phone': phone,
      'address': address,
      'email': email,
      'invoice_prefix': invoicePrefix,
      'next_invoice_number': nextInvoiceNumber,
      'terms': terms,
      'currency_symbol': currencySymbol,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'],
      businessName: map['business_name'] ?? 'My Business',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      invoicePrefix: map['invoice_prefix'] ?? 'INV-',
      nextInvoiceNumber: map['next_invoice_number'] ?? 1,
      terms: map['terms'] ?? '',
      currencySymbol: map['currency_symbol'] ?? '₹',
    );
  }
}

class Party {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String type; // 'customer' or 'supplier'
  final double openingBalance;
  final double currentBalance; // Positive: To Receive, Negative: To Pay
  final String createdAt;

  Party({
    this.id,
    required this.name,
    required this.phone,
    this.address = '',
    required this.type,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'type': type,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'created_at': createdAt,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      type: map['type'],
      openingBalance: (map['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] ?? '',
    );
  }
}

class Item {
  final int? id;
  final String name;
  final String category;
  final String unit; // PCS, KG, BOX, LTR, etc.
  final double purchasePrice;
  final double salePrice;
  final double currentStock;
  final double minStockAlert;
  final String barcode;

  Item({
    this.id,
    required this.name,
    this.category = 'General',
    this.unit = 'PCS',
    this.purchasePrice = 0.0,
    required this.salePrice,
    this.currentStock = 0.0,
    this.minStockAlert = 5.0,
    this.barcode = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'current_stock': currentStock,
      'min_stock_alert': minStockAlert,
      'barcode': barcode,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? 'General',
      unit: map['unit'] ?? 'PCS',
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      currentStock: (map['current_stock'] as num?)?.toDouble() ?? 0.0,
      minStockAlert: (map['min_stock_alert'] as num?)?.toDouble() ?? 5.0,
      barcode: map['barcode'] ?? '',
    );
  }
}
