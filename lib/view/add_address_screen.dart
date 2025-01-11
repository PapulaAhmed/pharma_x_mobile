import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';
import '../constants/location_constants.dart';
import '../viewmodel/add_address_viewmodel.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddAddressViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddAddressViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.saveAddress(context);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.error ?? 'Failed to save address')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Address'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _viewModel.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Address Title (e.g., Home, Work)',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _viewModel.streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter street address'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _viewModel.cityController,
                  decoration: const InputDecoration(
                    labelText: 'City/District',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter city' : null,
                ),
                const SizedBox(height: 16),
                Consumer<AddAddressViewModel>(
                  builder: (context, viewModel, _) =>
                      DropdownButtonFormField<String>(
                    value: viewModel.selectedState,
                    decoration: const InputDecoration(
                      labelText: 'Governorate',
                      prefixIcon: Icon(Icons.map),
                    ),
                    items:
                        LocationConstants.iraqiGovernorates.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Please select a governorate' : null,
                    onChanged: viewModel.setSelectedState,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _viewModel.zipController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter postal code'
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    child: const Text('Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
