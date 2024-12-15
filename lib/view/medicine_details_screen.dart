import 'package:flutter/material.dart';
import 'package:pharma_x/model/medicine_model.dart';
import 'package:pharma_x/viewmodel/cart_viewmodel.dart';
import 'package:provider/provider.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({Key? key, required this.medicine})
      : super(key: key);

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;
    final cart = Provider.of<CartViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                medicine.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.medication, size: 100);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              medicine.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Scientific Name: ${medicine.scientificName}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${medicine.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(
                      medicine.id, medicine.name, medicine.price, quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('$quantity ${medicine.name}(s) added to cart'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0)),
                child:
                    const Text('Add to Cart', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
