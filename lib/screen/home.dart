import 'package:flutter/material.dart';
import 'package:stark_atendimento/screen/chat_screen.dart';
import 'package:stark_atendimento/ui/extensions/size_screen_extension.dart';

import 'chat_atendente.dart';
import 'widgets/expantion_tile_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool bAparecer = false;
  String _sharedText = '';
  String atendente = '';

  void _updateText(String text) {
    setState(() {
      _sharedText = text;
    });
  }

  void _updateBAparecer(bool value) {
    setState(() {
      bAparecer = value;
    });
  }

  void _updateAtendente(String name) {
    setState(() {
      atendente = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side Menu
                    Container(
                      height: 900,
                      color: const Color(0xffF7F9FA),
                      width: 150,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Image(
                                image: AssetImage(
                                  'assets/stark.png',
                                ),
                                height: 60,
                              ) // Replace with your actual logo
                              ),
                          StatementTile(),
                          // MembersTile(),
                          // InvestmentsTile(),
                          // ReceivablesTile(),
                          // CorporateCardTile(),
                          // IntegrationsTile(),
                          // OperationsTile(),
                          // PayablesTile(),
                          SizedBox(
                            height: 75,
                          ),
                          AccountTile(),
                        ],
                      ),
                    ),
                    // Right Side Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text('Atendimentos',
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 20.0),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Container(
                                    width: 250,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: const Color(0xFF0070E0))),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          bAparecer = !bAparecer;
                                        });
                                      },
                                      child: const Text(
                                        'Atendimento',
                                        style:
                                            TextStyle(color: Color(0xFF0070E0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            bAparecer
                                ? Center(
                                    child: Text(
                                      'Atendente: $atendente',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container(),
                            bAparecer
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 700.h,
                                          decoration: const BoxDecoration(
                                              // color: Colors.blue,
                                              ),
                                          child: ChatAtendente(
                                            onTextSubmitted: _updateText,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 700.h,
                                          decoration: const BoxDecoration(
                                              // color: Colors.yellow,
                                              ),
                                          child: ChatScreen(
                                            textToPopulate: _sharedText,
                                            onButtonPressed: () {
                                              _updateBAparecer(false);
                                            },
                                            onAtendenteUpdated:
                                                _updateAtendente,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
