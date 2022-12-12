import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signInWithGoogle() async {
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();
    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Googleログイン')),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await signInWithGoogle();
              //pageが必ずあるよというためのmounted
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                    (route) => true);
              }
            },
            child: const Text('ログイン')),
      ),
    );
  }
}
