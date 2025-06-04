import 'package:flutter/material.dart';
import 'email.dart';

class ComposeEmailScreen extends StatefulWidget {
  final Function(Email) onSend;
  final Function(Email) onSaveDraft;
  final Email? emailToReply;

  ComposeEmailScreen({
    required this.onSend,
    required this.onSaveDraft,
    this.emailToReply,
  });

  @override
  _ComposeEmailScreenState createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  double _fontSize = 14.0; 
  String _fontFamily = 'Roboto'; 
  String _initialContent = ''; 
  bool _isSent = false; 

  @override
  void initState() {
    super.initState();
    if (widget.emailToReply != null) {
      _toController.text = widget.emailToReply!.sender;
      _subjectController.text = "Re: ${widget.emailToReply!.subject}";
      _contentController.text = "\n\nOn ${widget.emailToReply!.time.toString().split('.')[0]}, ${widget.emailToReply!.sender} wrote:\n${widget.emailToReply!.content}";
    }
    _initialContent = _contentController.text; 
  }

  @override
  void dispose() {
    if (!_isSent) {
      _autoSaveDraft(); 
    }
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _sendEmail() {
    final email = Email(
      sender: "You",
      to: _toController.text,
      cc: _ccController.text,
      bcc: _bccController.text,
      subject: _subjectController.text,
      content: _contentController.text,
      time: DateTime.now(),
    );
    _isSent = true; 
    widget.onSend(email);
    Navigator.pop(context);
  }

  void _autoSaveDraft() {
    if (!_isSent && _contentController.text != _initialContent && _contentController.text.isNotEmpty) {
      final email = Email(
        sender: "You",
        to: _toController.text,
        cc: _ccController.text,
        bcc: _bccController.text,
        subject: _subjectController.text,
        content: _contentController.text,
        time: DateTime.now(),
        isDraft: true,
      );
      widget.onSaveDraft(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _autoSaveDraft(); 
        return true;
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Compose Email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _toController,
                decoration: InputDecoration(labelText: "To"),
              ),
              TextField(
                controller: _ccController,
                decoration: InputDecoration(labelText: "CC"),
              ),
              TextField(
                controller: _bccController,
                decoration: InputDecoration(labelText: "BCC"),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: "Subject"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<double>(
                    value: _fontSize,
                    items: [12.0, 14.0, 16.0].map((double size) {
                      return DropdownMenuItem<double>(
                        value: size,
                        child: Text("$size pt"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fontSize = value;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: _fontFamily,
                    items: ['Roboto', 'Arial', 'Times New Roman'].map((String font) {
                      return DropdownMenuItem<String>(
                        value: font,
                        child: Text(font, style: TextStyle(fontFamily: font)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fontFamily = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: "Content"),
                maxLines: 10,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontFamily: _fontFamily,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _sendEmail,
                    child: Text("Send"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}