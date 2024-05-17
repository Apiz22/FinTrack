import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Badges {
  Future<void> awardBadge(String badgeName, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        QuerySnapshot userBadges = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('user_badges')
            .where('name', isEqualTo: badgeName)
            .get();

        if (userBadges.docs.isEmpty) {
          QuerySnapshot badgeSnapshot = await firestore
              .collection('badges')
              .where('name', isEqualTo: badgeName)
              .get();

          if (badgeSnapshot.docs.isNotEmpty) {
            var badgeData =
                badgeSnapshot.docs.first.data() as Map<String, dynamic>;
            await firestore
                .collection('users')
                .doc(user.uid)
                .collection('user_badges')
                .add({
              'badgeId': badgeSnapshot.docs.first.id,
              'timestamp': FieldValue.serverTimestamp(),
              'name': badgeData['name'],
              'description': badgeData['description'],
              'imageUrl': badgeData['imageUrl'],
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Congratulations! You have been awarded a badge.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Badge not found.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You have already been awarded this badge.')),
          );
        }
      } else {
        throw Exception("User document not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error awarding badge: $e')),
      );
    }
  }
}
