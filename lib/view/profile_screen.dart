import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_x/viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final userData = viewModel.userData ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Section
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: userData['firstName'] ?? '',
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) => _firstName = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: userData['lastName'] ?? '',
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) => _lastName = value,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        viewModel.updateUserProfile(
                          firstName: _firstName!,
                          lastName: _lastName!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Address Section
            const Text(
              'Addresses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: (userData['addresses'] as List<dynamic>? ?? []).map(
                  (address) {
                    return ListTile(
                      title: Text(address['title']),
                      subtitle: Text(address['details']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          viewModel.removeAddress(address['id']);
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final titleController = TextEditingController();
                    final detailsController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add Address'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                          ),
                          TextField(
                            controller: detailsController,
                            decoration:
                                const InputDecoration(labelText: 'Details'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            viewModel.addAddress(
                              titleController.text,
                              detailsController.text,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Add Address'),
            ),
          ],
        ),
      ),
    );
  }
}
