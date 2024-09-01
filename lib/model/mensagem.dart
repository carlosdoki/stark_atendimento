import 'dart:convert';

class Mensagem {
  String content;
  String sentiment;
  String response;
  String skill;
  Mensagem({
    required this.content,
    required this.sentiment,
    required this.response,
    required this.skill,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'sentiment': sentiment,
      'response': response,
      'skill': skill,
    };
  }

  factory Mensagem.fromMap(Map<String, dynamic> map) {
    return Mensagem(
      content: map['content'] ?? '',
      sentiment: map['sentiment'] ?? '',
      response: map['response'] ?? '',
      skill: map['skill'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Mensagem.fromJson(String source) =>
      Mensagem.fromMap(json.decode(source));
}
