class Product {
  String? id; // Will be the Firestore document ID
  String name;
  double price;
  String description;

  Product({this.id, required this.name, required this.price, required this.description});

  // Convert a Product object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }

  // Create a Product object from a Firestore document snapshot
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(), // Handle num from Firestore
      description: map['description'] as String,
    );
  }
}

