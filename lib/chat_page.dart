import 'package:chat_practice/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'account_page.dart';
import 'main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final helloContoller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    helloContoller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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

                          return Slidable(
                              startActionPane: ActionPane(
                                // (2)
                                extentRatio: 0.2,
                                motion: const ScrollMotion(), // (5)
                                children: [
                                  FirebaseAuth.instance.currentUser?.uid ==
                                          post.posterId
                                      ? Expanded(
                                          child: Row(
                                            children: [
                                              SlidableAction(
                                                onPressed: (_) {
                                                  post.reference.delete();
                                                },
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.red,
                                                icon: Icons.delete,
                                                label: 'Dleate',
                                              ),
                                              SlidableAction(
                                                onPressed: (_) {
                                                  showDialog(
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title:
                                                              const Text('編集'),
                                                          content:
                                                              TextFormField(
                                                            initialValue:
                                                                post.text,
                                                            autofocus: true,
                                                            onFieldSubmitted:
                                                                (newText) {
                                                              post.reference
                                                                  .update({
                                                                'text': newText
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      context: context);
                                                },
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.blue,
                                                icon: Icons.edit,
                                                label: 'Edit',
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              child: PostWidget(post: post));
                        },
                        itemCount: posts.length,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      controller: helloContoller,
                      autofocus: true,
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
                        helloContoller.clear();
                      },
                      decoration: const InputDecoration(
                        hintText: "What's up",
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow)),
                      )),
                ),
              ],
            ),
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
