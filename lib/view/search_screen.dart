import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_x/model/medicine_model.dart';
import 'package:pharma_x/viewmodel/medicine_viewmodel.dart';
import 'package:pharma_x/widgets/medicine_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search medicines...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (value) {
            Provider.of<MedicineViewModel>(context, listen: false)
                .searchMedicines(value);
          },
        ),
      ),
      body: Consumer<MedicineViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          final medicines = viewModel.medicines;

          if (medicines.isEmpty) {
            return const Center(
              child: Text('No medicines found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: medicines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return MedicineCard(medicine: medicines[index]);
            },
          );
        },
      ),
    );
  }
}
