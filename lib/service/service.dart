import 'package:cloud_firestore/cloud_firestore.dart';

import '../datamodel.dart';

class ProductService {
  final CollectionReference _productCollection =
  FirebaseFirestore.instance.collection('products'); // 'products' is your collection name



  Future<void> addProduct(Product product) async {
    await _productCollection.add(product.toMap());
  }
  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
  Future<void> updateProduct(Product product) async {
    if (product.id == null) { /* Handle error */ }
    await _productCollection.doc(product.id).update(product.toMap());
  }
  Future<void> deleteProduct(String productId) async {
    await _productCollection.doc(productId).delete();
  }
}