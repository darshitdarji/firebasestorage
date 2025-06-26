import 'package:flutter/material.dart';
import 'package:newfirebase/service/service.dart';

import 'add_edit_product_screen.dart';
import 'datamodel.dart';
// Import the add/edit screen

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products List'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        // Listen to the stream of products from our service
        stream: ProductService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Display an error message if something goes wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Message when there are no products
            return const Center(child: Text('No products found. Add one!'));
          }

          // Data has arrived, build the list
          List<Product> products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                      Text(product.description),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to the AddEditProductScreen for editing
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditProductScreen(productToEdit: product),
                            ),
                          );
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Show a confirmation dialog before deleting
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text(
                                  'Are you sure you want to delete "${product.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                              false; // Default to false if dialog is dismissed

                          if (confirmDelete && product.id != null) {
                            try {
                              await ProductService().deleteProduct(product.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.name} deleted successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete product: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button to add new products
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddEditProductScreen for adding a new product
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Product',
      ),
    );
  }
}