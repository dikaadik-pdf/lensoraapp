import 'package:cashierapp_simulationukk2026/models/produk_model.dart';

class CartItemModel {
  final ProdukModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.harga * quantity;

  void incrementQuantity() {
    if (quantity < product.stok) {
      quantity++;
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  void setQuantity(int newQuantity) {
    if (newQuantity > 0 && newQuantity <= product.stok) {
      quantity = newQuantity;
    }
  }
}