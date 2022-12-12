import 'package:chat_practice/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(    
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

//Firestoreにデータを渡せるようにdataの変換を行う
final postReference = FirebaseFirestore.instance
    .collection('posts')
    .withConverter<Post>(fromFirestore: (documentSnapshot, _) {
      //documentSnapshotを受け取ってPostインスタンスをリターンする　postインスタンスを生成して、戻す
  return Post.fromFirestore(documentSnapshot);
}, toFirestore: (data, _) {
  //dataをFirestoreに保存できるように変換する
  return data.toMap();
});
