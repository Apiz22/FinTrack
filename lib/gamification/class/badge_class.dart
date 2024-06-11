import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Badges {
  Future<void> awardBadge(String badgeName, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final firestore = FirebaseFirestore.instance;
      final currentDate = DateFormat('MMM y').format(DateTime.now());

      // Check if the user document exists
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception("User document not found");
      }

      // Check if the badge has already been awarded in the current month
      final userBadgesQuery = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('user_badges')
          .where('name', isEqualTo: badgeName)
          .where('monthYear', isEqualTo: currentDate)
          .get();

      if (userBadgesQuery.docs.isNotEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Badge already awarded this month.')),
        // );
        return;
      }

      // Get the badge details
      final badgeQuery = await firestore
          .collection('badges')
          .where('name', isEqualTo: badgeName)
          .get();

      if (badgeQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Badge not found.')),
        );
        return;
      }

      final badgeData = badgeQuery.docs.first.data();
      final badgeId = badgeQuery.docs.first.id;

      // Award the badge to the user
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('user_badges')
          .add({
        'badgeId': badgeId,
        'timestamp': FieldValue.serverTimestamp(),
        'name': badgeData['name'],
        'description': badgeData['description'],
        'imageUrl': badgeData['imageUrl'],
        'monthYear': currentDate,
      });

      await updateTotalBadges(user.uid, currentDate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Congratulations! You have been awarded a badge.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error awarding badge: $e')),
      );
    }
  }

  Future<void> updateTotalBadges(String userId, String currentDate) async {
    final firestore = FirebaseFirestore.instance;

    // Get the total number of badges
    final userBadgesQuery = await firestore
        .collection('users')
        .doc(userId)
        .collection('user_badges')
        .where('monthYear', isEqualTo: currentDate)
        .get();

    final totalBadgesObtained = userBadgesQuery.docs.length;

    // Update the total badges count in the user document
    await firestore.collection('users').doc(userId).update({
      'totalBadgesObtained': totalBadgesObtained,
    });
  }

  Future<int> retrieveTotalBadge(String monthYear) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final firestore = FirebaseFirestore.instance;

      // Get the total number of badges
      final userBadgesQuery = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('user_badges')
          .where('monthYear', isEqualTo: monthYear)
          .get();

      final totalBadgesObtained = userBadgesQuery.docs.length;

      // Update the total badges count in the user document
      await firestore.collection('users').doc(user.uid).update({
        'totalBadgesObtained': totalBadgesObtained,
      });

      return totalBadgesObtained;
    } catch (e) {
      print("Error retrieving total badges: $e");
      return 0;
    }
  }

  Stream<List<QueryDocumentSnapshot>> retrieveBadgesList(String currentDate) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('user_badges')
        .where('monthYear', isEqualTo: currentDate)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
