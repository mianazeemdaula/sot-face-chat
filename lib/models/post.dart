import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String? id;
  final String userId;
  final String body;
  final int comments;
  final List<String> likes;
  final String? image;
  final DateTime createdAt;

  Post({
    this.id,
    required this.userId,
    required this.body,
    required this.comments,
    required this.likes,
    required this.createdAt,
    this.image,
  });

  factory Post.create({
    required body,
    required String userId,
    String? image,
  }) {
    return Post(
      body: body,
      userId: userId,
      comments: 0,
      likes: [],
      createdAt: DateTime.now(),
      image: image,
    );
  }

  factory Post.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Post(
      id: snapshot.id,
      userId: snapshot.data()['user_id'],
      body: snapshot.data()['body'] ?? snapshot.data()['message'],
      comments: snapshot.data()['comments'],
      likes: List.from(snapshot.data()['likes']),
      image: snapshot.data()['image'],
      createdAt: snapshot.data()['created_at'] == null
          ? DateTime.now()
          : snapshot.data()['created_at'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'user_id': userId,
      'comments': comments,
      'likes': likes,
      'created_at': FieldValue.serverTimestamp(),
      'image': image,
    };
  }

  bool get isLiked => likes.contains(FirebaseAuth.instance.currentUser!.uid);
}
