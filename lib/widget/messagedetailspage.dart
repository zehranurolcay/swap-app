import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagesPage extends StatefulWidget {
  final int loggedUserId;
  final int selectedUserId;
  final String selectedUserName;

  MessagesPage({
    required this.loggedUserId,
    required this.selectedUserId,
    required this.selectedUserName,
  });

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? offerId;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    loadMessages();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8080'),
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);

      if ((data['receiver_id'] == widget.loggedUserId &&
          data['sender_id'] == widget.selectedUserId) ||
          (data['sender_id'] == widget.loggedUserId &&
              data['receiver_id'] == widget.selectedUserId)) {
        setState(() {
          messages.add({
            'message': data['message'],
            'sender_id': data['sender_id'],
          });
        });
        scrollToBottom();
      }
    });
  }

  Future<void> loadMessages() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/api/load-message?sender=${widget.loggedUserId}&receiver=${widget.selectedUserId}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
        offerId = data.firstWhere((msg) => msg['offer_id'] != null,
            orElse: () => {})['offer_id'];
      });
      scrollToBottom();
    }
  }

  void sendMessage() {
    if (messageController.text.isEmpty) return;

    final message = {
      'sender_id': widget.loggedUserId,
      'receiver_id': widget.selectedUserId,
      'message': messageController.text,
      'offer_id': offerId
    };

    channel.sink.add(jsonEncode(message));

    setState(() {
      messages.add({
        'message': messageController.text,
        'sender_id': widget.loggedUserId,
      });
      messageController.clear();
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedUserName),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: messages
                  .map(
                    (msg) => Align(
                  alignment:
                  msg['sender_id'] == widget.loggedUserId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: msg['sender_id'] == widget.loggedUserId
                          ? Colors.green[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['message'],
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration:
                  InputDecoration(hintText: "Mesajınızı yazın..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          ),
        ],
      ),
    );
  }
}
