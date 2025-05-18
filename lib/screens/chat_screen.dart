import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/tts_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String currentUserPhone;
  final User otherUser;

  const ChatScreen({
    Key? key,
    required this.currentUserPhone,
    required this.otherUser,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService(baseUrl: 'http://192.168.1.188/TALKTEXT');
  final TtsService _tts = TtsService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  List<Message> _messages = [];
  bool _isListening = false;
  String _recognizedText = '';
  String _currentLanguage = 'en'; // Default to English
  String _speechLocale = 'en_US';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference().then((_) {
      _loadMessages();
      _initializeSpeech();
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _loadMessages();
    });
  }

  Future<void> _loadLanguagePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
      _speechLocale = _currentLanguage == 'sw' ? 'sw_TZ' : 'en_US';
    });
    await _tts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translate('speechNotAvailable'))),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    List<Message> messages = await _chatService.getMessages(
      senderPhone: widget.currentUserPhone,
      receiverPhone: widget.otherUser.phone,
    );
    if (mounted) {
      setState(() => _messages = messages);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              _messageController.text = _recognizedText;
            });
          },
          listenFor: const Duration(minutes: 1),
          pauseFor: const Duration(seconds: 3),
          localeId: _speechLocale,
        );
      }
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      await _chatService.sendMessage(
        senderPhone: widget.currentUserPhone,
        receiverPhone: widget.otherUser.phone,
        message: messageText,
      );
      _messageController.clear();
      _loadMessages();

      // Announce message sent in selected language
      String confirmation = _translate('messageSent');
      await _tts.speak(confirmation);
    }
  }

  Future<void> _playMessage() async {
    String text = _messageController.text;
    if (text.isNotEmpty) {
      // Use detected language for the message content
      bool isSwahili = _detectSwahili(text);
      await _tts.setLanguage(isSwahili ? 'sw-TZ' : 'en-US');
      await _tts.speak(text);
    }
  }

  Future<void> _announceMessage(Message message) async {
    bool isSender = message.senderPhone == widget.currentUserPhone;
    bool isSwahili = _detectSwahili(message.message);

    // First announce who sent the message in selected language
    await _tts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
    String announcement = isSender
        ? "${_translate('youSaid')}:"
        : "${widget.otherUser.username} ${_translate('said')}:";
    await _tts.speak(announcement);

    // Then speak the message in its original language
    await _tts.setLanguage(isSwahili ? 'sw-TZ' : 'en-US');
    await _tts.speak(message.message);
  }

  bool _detectSwahili(String text) {
    const swahiliKeywords = [
      'mambo', 'poa', 'safi', 'asante', 'karibu',
      'ndiyo', 'hapana', 'sawa', 'hapana', 'nzuri',
      'rafiki', 'shule', 'mwalimu', 'chakula', 'maji'

          'nyumbani', 'njoo', 'sasahivi', 'nielekeze', 'sawa'];
    final lowerText = text.toLowerCase();
    return swahiliKeywords.any((word) => lowerText.contains(word));
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.parse(timestamp);
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}";
  }

  String _translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'chatWith': {
        'en': 'Chat with',
        'sw': 'Mazungumzo na'
      },
      'speakingWith': {
        'en': 'You are speaking with',
        'sw': 'Unaongea na'
      },
      'writeOrSpeak': {
        'en': 'Write or speak a message',
        'sw': 'Andika au sema ujumbe'
      },
      'youSaid': {
        'en': 'You said',
        'sw': 'Ulisema'
      },
      'said': {
        'en': 'said',
        'sw': 'alisema'
      },
      'speechNotAvailable': {
        'en': 'Speech recognition not available',
        'sw': 'Utambuzi wa sauti haupatikani'
      },
      'messageSent': {
        'en': 'Message sent',
        'sw': 'Ujumbe umetumwa'
      },
    };

    return translations[key]?[_currentLanguage] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_translate('chatWith')} ${widget.otherUser.username}"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              _tts.setLanguage(_currentLanguage == 'sw' ? 'sw-TZ' : 'en-US');
              _tts.speak("${_translate('speakingWith')} ${widget.otherUser.username}");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message.senderPhone == widget.currentUserPhone;

                return GestureDetector(
                  onTap: () => _announceMessage(message),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.lightBlueAccent : Colors.blue,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: GoogleFonts.poppins(
                                color: Colors.grey[200],
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: _isListening ? Colors.red : Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: _translate('writeOrSpeak'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.blue,
                  onPressed: _playMessage,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}