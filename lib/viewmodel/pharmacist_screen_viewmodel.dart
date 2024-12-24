import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class PharmacistHomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Chat> _recentChats = [];
  List<Chat> get recentChats => _recentChats;

  bool _isLoadingChats = false;
  bool get isLoadingChats => _isLoadingChats;

  Future<void> fetchRecentChats() async {
    _isLoadingChats = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('chats') // Fetch all chat documents
          .orderBy('lastUpdated', descending: true) // Order by recent activity
          .limit(5) // Limit to recent 5
          .get();

      _recentChats = querySnapshot.docs
          .map((doc) => Chat.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching recent chats: $e");
    } finally {
      _isLoadingChats = false;
      notifyListeners();
    }
  }
}
