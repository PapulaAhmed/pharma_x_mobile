import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_x/view/add_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Function(String address, String paymentMethod) onConfirm;

  const CheckoutScreen({Key? key, required this.onConfirm}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  String _paymentMethod = 'Cash';

  // User information
  String _fullName = '';
  String _phoneNumber = '';
  String _email = '';
  bool _isLoading = true;

  // Text editing controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            _fullName =
                '${userData['firstName']} ${userData['lastName']}'.trim();
            _phoneNumber = userData['phoneNumber'] ?? '';
            _email = user.email ?? '';

            _nameController.text = _fullName;
            _phoneController.text = _phoneNumber;
            _emailController.text = _email;

            // Load addresses
            if (userData.data()!.containsKey('addresses')) {
              _addresses = List<Map<String, dynamic>>.from(
                  userData.data()!['addresses'] ?? []);
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Split the full name into first and last name
        final nameParts = _nameController.text.trim().split(' ');
        final firstName = nameParts.first;
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': _phoneController.text.trim(),
        });

        // Update email if changed
        if (_emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update information: $e')),
      );
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && userData.data()!.containsKey('addresses')) {
          setState(() {
            _addresses = List<Map<String, dynamic>>.from(
                userData.data()!['addresses'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personal Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _updateUserInfo,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Editable user information
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const Divider(height: 32),

                // Address Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedAddressId,
                  decoration: const InputDecoration(
                    labelText: 'Select Address',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ..._addresses.map((address) => DropdownMenuItem(
                          value: address['id'],
                          child: Text(
                              '${address['title']}: ${address['street']}, ${address['city']}'),
                        )),
                    const DropdownMenuItem(
                      value: 'new',
                      child: Text('+ Add New Address'),
                    ),
                  ],
                  validator: (value) =>
                      value == null ? 'Please select an address' : null,
                  onChanged: (value) async {
                    if (value == 'new') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadAddresses(); // Reload addresses after adding new one
                      }
                    } else {
                      setState(() {
                        _selectedAddressId = value;
                        final selectedAddress = _addresses
                            .firstWhere((addr) => addr['id'] == value);
                        _address =
                            '${selectedAddress['street']}, ${selectedAddress['city']}, ${selectedAddress['state']} ${selectedAddress['zip']}';
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Payment Method
                const Text(
                  'Select Payment Method:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Cash'),
                  leading: Radio<String>(
                    value: 'Cash',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Credit Card'),
                  leading: Radio<String>(
                    value: 'Credit Card',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onConfirm(_address, _paymentMethod);
                      }
                    },
                    child: const Text('Confirm and Place Order'),
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
