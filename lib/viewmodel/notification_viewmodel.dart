import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<QuerySnapshot>? _readStatusSubscription;

  int _unreadCount = 0;
  List<Map<String, dynamic>> _notifications = [];
  Set<String> _readNotificationIds = {};
  String? _userRole;

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;

  NotificationViewModel() {
    _getUserRoleAndInitialize();
  }

  Future<void> _getUserRoleAndInitialize() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get user role
        final doc = await _firestore.collection('users').doc(user.uid).get();
        _userRole = doc.data()?['role'];
        print('User role: $_userRole'); // Debug log

        if (_userRole != null) {
          await _setupNotificationStream();
          await _setupReadStatusStream(user.uid);
        }
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _setupNotificationStream() async {
    _notificationSubscription?.cancel();
    _notificationSubscription = _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: _userRole)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      print(
          'Received notification update: ${snapshot.docs.length} items'); // Debug
      _notifications =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _updateUnreadCount();
    });
  }

  Future<void> _setupReadStatusStream(String userId) async {
    _readStatusSubscription?.cancel();
    _readStatusSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('readNotifications')
        .snapshots()
        .listen((snapshot) {
      print(
          'Received read status update: ${snapshot.docs.length} items'); // Debug
      _readNotificationIds = snapshot.docs.map((doc) => doc.id).toSet();
      _updateUnreadCount();
    });
  }

  Future<void> refreshNotifications() async {
    await _getUserRoleAndInitialize();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications
        .where((notification) =>
            !_readNotificationIds.contains(notification['id']))
        .length;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _readStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('readNotifications')
        .doc(notificationId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    _updateUnreadCount();
  }

  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    for (var notification in _notifications) {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('readNotifications')
          .doc(notification['id']);
      batch.set(ref, {
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    _updateUnreadCount();
  }
}
