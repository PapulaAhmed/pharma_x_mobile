import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_x/model/medicine_model.dart';
import 'package:pharma_x/widgets/medicine_card.dart';

class MedicinesDisplay extends StatelessWidget {
  const MedicinesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medicine').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No medicines available'),
          );
        }

        // Map Firestore data to Medicine model
        final medicines = snapshot.data!.docs.map((doc) {
          return Medicine.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // Display medicines in a grid
        return GridView.builder(
          shrinkWrap: true, // Limit the height of the grid to fit the content
          physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
          itemCount: medicines.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display two cards per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 4, // Adjust height of the cards
          ),
          itemBuilder: (context, index) {
            return MedicineCard(medicine: medicines[index]);
          },
        );
      },
    );
  }
}
