import 'package:chat_practice/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'account_page.dart';
import 'main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatPage'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyPage()));

              print('tap');
            },
            child: CircleAvatar(
              backgroundImage:
                  NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
            ),
          )
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Post>>(
                  stream: postReference
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final posts = snapshot.data?.docs ??
                        []; //dataがnullの場合は空配列を渡すので、エラーにはならない

                    return ListView.builder(
                      itemBuilder: (BuildContext context, index) {
                        //上の処理でリスト全体が入ってくるので、一個一個のデータをとる処理をする
                        final post = posts[index].data();

                        return PostWidget(post: post);
                      },
                      itemCount: posts.length,
                    );
                  },
                ),
              ),
              TextFormField(
                  onFieldSubmitted: (text) {
                    final newDocumentReference = postReference.doc();

                    final user = FirebaseAuth.instance.currentUser!;
                    final newPost = Post(
                        createdAt: Timestamp.now(),
                        posterId: user.uid,
                        posterImageUrl: user.photoURL!,
                        posterName: user.displayName!,
                        //'/post/documentID'
                        reference: postReference.doc(),
                        text: text);
                    //postDataの保存
                    //本来であれば、<map<String dynamic>>の形で渡さないといけないけど、WithConverterで変換しているので、このまま渡せる。
                    newDocumentReference.set(newPost);
                  },
                  decoration: const InputDecoration(
                    hintText: 'What do people call you?',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(post.posterImageUrl)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  FirebaseAuth.instance.currentUser!.uid == post.posterId
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(post.posterName),
                    Text(DateFormat('MM/dd/HH:mm')
                        .format(post.createdAt.toDate())),
                  ],
                ),
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: FirebaseAuth.instance.currentUser!.uid ==
                                post.posterId
                            ? Colors.amber
                            : Colors.red),
                    child: Text(post.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
