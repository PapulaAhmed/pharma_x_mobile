import 'package:flutter/material.dart';
import 'package:pharma_x/viewmodel/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.itemCount == 0
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itemCount,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} x \$${item.price}'),
                        trailing:
                            Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          onConfirm: (address, paymentMethod) async {
                            try {
                              await cart.createOrderFromCart(
                                address: address,
                                paymentMethod: paymentMethod,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully!'),
                                ),
                              );
                              Navigator.pop(context); // Close CheckoutScreen
                              Navigator.pop(context); // Close CartScreen
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to place order: $error'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Proceed to Checkout'),
                ),
              ],
            ),
    );
  }
}
