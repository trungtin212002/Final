import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'email.dart';
import 'compose_email_screen.dart';

class ViewEmailScreen extends StatefulWidget {
  final Email email;
  final Function(Email) onSend;
  final Function(Email) onSaveDraft;
  final Function(Email) onUpdateEmail;

  const ViewEmailScreen({
    required this.email,
    required this.onSend,
    required this.onSaveDraft,
    required this.onUpdateEmail,
  });

  @override
  _ViewEmailScreenState createState() => _ViewEmailScreenState();
}

class _ViewEmailScreenState extends State<ViewEmailScreen> {
  late Email email;

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  void _updateEmail(Email updatedEmail) {
    setState(() {
      email = updatedEmail;
    });
    widget.onUpdateEmail(updatedEmail);
  }

  void _assignLabel(String label, bool add) {
    if (add && !email.labels.contains(label)) {
      _updateEmail(email.copyWith(labels: [...email.labels, label]));
    } else if (!add && email.labels.contains(label)) {
      _updateEmail(email.copyWith(labels: email.labels.where((l) => l != label).toList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(email.subject),
          IconButton(
            icon: Icon(email.isStarred ? Icons.star : Icons.star_border),
            color: email.isStarred ? Colors.yellow : null,
            onPressed: () {
              _updateEmail(email.copyWith(isStarred: !email.isStarred));
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("From: ${email.sender}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Time: ${DateFormat('MMM d, yyyy h:mm a').format(email.time)}", style: TextStyle(color: Colors.grey)),
            Text("Read: ${email.isRead ? 'Yes' : 'No'}", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Html(data: email.content),
            SizedBox(height: 8),
            if (email.attachments.isNotEmpty) ...[
              Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...email.attachments.map((attachment) => Text(attachment)).toList(),
            ],
            if (email.labels.isNotEmpty) ...[
              Text("Labels:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: email.labels.map((label) => Chip(
                  label: Text(label),
                  onDeleted: () => _assignLabel(label, false),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ComposeEmailScreen(
                onSend: widget.onSend,
                onSaveDraft: widget.onSaveDraft,
                emailToReply: email,
              ),
            );
          },
          child: Text("Reply"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ComposeEmailScreen(
                onSend: widget.onSend,
                onSaveDraft: widget.onSaveDraft,
              ),
            );
          },
          child: Text("Forward"),
        ),
        IconButton(
          icon: Icon(email.isRead ? Icons.mark_email_read : Icons.mark_email_unread),
          onPressed: () {
            _updateEmail(email.copyWith(isRead: !email.isRead));
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _updateEmail(email.copyWith(isInTrash: true));
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}