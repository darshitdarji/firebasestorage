import 'package:flutter/material.dart';

import 'package:newfirebase/service/service.dart';

import 'datamodel.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? productToEdit; // Null if adding, non-null if editing

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Initialize controllers with existing product data if editing
  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _descriptionController.text = widget.productToEdit!.description;
    }
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to save (add or update) the product
  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, extract data
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final description = _descriptionController.text;

      try {
        if (widget.productToEdit == null) {
          // It's a new product, call addProduct
          final newProduct = Product(
            name: name,
            price: price,
            description: description,
          );
          await ProductService().addProduct(newProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        } else {
          // It's an existing product, call updateProduct
          final updatedProduct = Product(
            id: widget.productToEdit!.id, // Ensure ID is passed for update
            name: name,
            price: price,
            description: description,
          );
          await ProductService().updateProduct(updatedProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
        Navigator.pop(context); // Go back to the product list screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productToEdit == null ? 'Add Product' : 'Edit Product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associate the form key
          child: ListView(
            children: [
              // Product Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3, // Allow multiple lines for description
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveProduct,
                icon: Icon(widget.productToEdit == null ? Icons.add : Icons.save),
                label: Text(widget.productToEdit == null ? 'Add Product' : 'Update Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}