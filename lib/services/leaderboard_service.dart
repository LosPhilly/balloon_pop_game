import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitScore(String playerName, int score) async {
    try {
      await _firestore.collection('leaderboard').add({
        'playerName': playerName,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Score submitted successfully');
    } catch (e) {
      print('Failed to submit score: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Failed to get leaderboard: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchPlayerScore(
      String playerName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('leaderboard')
          .where('playerName', isEqualTo: playerName)
          .orderBy('score', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Failed to search for player score: $e');
      return [];
    }
  }
}
