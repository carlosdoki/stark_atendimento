import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/mensagem.dart';

class ChatScreen extends StatefulWidget {
  final String textToPopulate;
  final VoidCallback onButtonPressed; // Callback for button press

  const ChatScreen(
      {super.key, required this.textToPopulate, required this.onButtonPressed});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _collectionAStream;
  String docIdAnt = '';

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textToPopulate != oldWidget.textToPopulate) {
      _messageController.text = widget.textToPopulate;
    }
  }

  @override
  void initState() {
    super.initState();

    _collectionAStream = firestore.collection('messages').snapshots();
    _collectionAStream.listen((QuerySnapshot snapshot) {
      for (var documentChange in snapshot.docChanges) {
        if (documentChange.type == DocumentChangeType.added) {
          _handleUpdate(documentChange.doc);
        }
      }
    });
  }

  void _handleUpdate(DocumentSnapshot updatedDoc) async {
    try {
      // Get the updated data from the document
      Map<String, dynamic> updatedData =
          updatedDoc.data() as Map<String, dynamic>;

      // Define the ID for the corresponding document in `collectionB`
      String docId = updatedDoc.id;
      DocumentSnapshot docB =
          await firestore.collection('starkai').doc(docId).get();

      if (!docB.exists && updatedData['sender'] == 'client') {
        Dio dio = Dio();

        Mensagem mensagem = Mensagem(
          content: updatedData['message'],
          sentiment: '',
          response: '',
          skill: '',
        );
        late String resposta = '';

        try {
          if (docIdAnt != docId) {
            docIdAnt = docId;
            Response response = await dio.post(
              'https://0fb6-179-42-27-126.ngrok-free.app/msg',
              options: Options(
                headers: {'Content-Type': 'application/json'},
              ),
              data: mensagem.toMap(),
            );

            await firestore.collection('messages').doc(docId).set({
              'message': updatedData['message'],
              'sender': updatedData['sender'],
              'sentiment': response.data['sentiment'],
              'timestamp': FieldValue.serverTimestamp(),
            });
            resposta = response.data['response'];
            print(response.data);
          }
        } catch (e) {
          print('Error: $e');
        }

        // Create a new document in `collectionB` with the updated data
        await firestore.collection('starkai').doc(docId).set({
          'message': updatedData['message'], // Map fields as needed
          'sender': updatedData['cliente'],
          'timestamp':
              FieldValue.serverTimestamp(), // Optionally add a timestamp
        });
        if (resposta != '') {
          await firestore.collection('starkai').add({
            'message': resposta, // Map fields as needed
            'sender': 'ia',
            'timestamp':
                FieldValue.serverTimestamp(), // Optionally add a timestamp
          });
          resposta = '';
        }
      }
    } catch (e) {
      // Handle errors
      print('Error inserting document into collectionB: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      //Fazer chamada na API para verificar sentimento

      await firestore.collection('messages').add({
        'sender': 'agent',
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'sentiment': ''
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
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
            'Cliente: Hackathon Account 927903',
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
                  .collection('messages')
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
                    final sentiment = message['sentiment'] ?? '';
                    return Container(
                      padding: EdgeInsets.only(
                        left: message['sender'] != 'client' ? 50 : 0,
                        right: message['sender'] == 'client' ? 50 : 0,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                // padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: message['sender'] != 'client'
                                      ? const Color(0xFF2692FF)
                                      : const Color(0xFFF7F9FA),
                                  borderRadius: message['sender'] != 'client'
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                ),
                                child: ListTile(
                                  title: Text(message['message']),
                                  trailing: Text(formattedTime),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          message['sender'] == 'client' && sentiment != ''
                              ? Positioned(
                                  bottom: 10,
                                  right: 20,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF7F9FA),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: sentiment == 'mixed'
                                        ? Image.asset('assets/smile.png')
                                        : sentiment == 'negative'
                                            ? Image.asset('assets/mad.png')
                                            : sentiment == 'positive'
                                                ? Image.asset(
                                                    'assets/happy.png')
                                                : Image.asset('assets/sad.png'),
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
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              setState(() {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Atendimento finalizado'),
                      content: const Text('NPS automático medido: 5.0'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _messageController.text =
                                'Em uma escala de 0 a 5, o quanto você avaliaria o atendimento que acabou de ter a um amigo?';
                            _sendMessage();
                            widget.onButtonPressed();
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              });
            },
            child: const Text(
              'Finalizar atendimento',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
