import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/mensagem.dart';

class ChatAtendente extends StatefulWidget {
  final Function(String) onTextSubmitted;
  const ChatAtendente({super.key, required this.onTextSubmitted});

  @override
  State<ChatAtendente> createState() => _ChatAtendenteState();
}

class _ChatAtendenteState extends State<ChatAtendente> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await firestore.collection('starkai').add({
        'sender': 'client',
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: const Color(0xFF63B1FF),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ]),
      child: Column(
        children: [
          const Text(
            'STARK AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(
            color: Color(0xFFBDC4C9),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('starkai')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data!.docs[index];
                    final Timestamp timestamp =
                        message['timestamp'] ?? Timestamp.now();
                    DateTime dateTime = timestamp.toDate();
                    String formattedTime = DateFormat('HH:mm').format(dateTime);

                    return Padding(
                      padding: EdgeInsets.only(
                        left: message['sender'] == 'client'
                            ? 50
                            : message['sender'] == 'ia'
                                ? 50
                                : 0,
                        right: message['sender'] == 'client'
                            ? 0
                            : message['sender'] == 'ia'
                                ? 0
                                : 50,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: message['sender'] == 'client'
                                      ? const Color(0xFFF7F9FA)
                                      : message['sender'] == 'ia'
                                          ? const Color(0xFF0070E0)
                                          : const Color(
                                              0xFFBDC4C9), // Custom color for text bubble
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(message['message'],
                                      style: TextStyle(
                                          color: message['sender'] == 'ia'
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 20,
                            right: 10,
                            child: Text(formattedTime),
                          ),
                          message['sender'] == 'ia'
                              ? Positioned(
                                  bottom: 30,
                                  right: 10,
                                  child: IconButton(
                                    tooltip: 'Enviar resposta para o cliente',
                                    onPressed: () {
                                      widget
                                          .onTextSubmitted(message['message']);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
