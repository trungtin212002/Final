import 'package:flutter/material.dart';
import 'email.dart';
import 'menu_item.dart';
import 'compose_email_screen.dart';
import 'view_email_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: GmailUI(onToggleTheme: toggleTheme, isDarkTheme: isDarkTheme),
    );
  }
}

class GmailUI extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkTheme;

  GmailUI({required this.onToggleTheme, required this.isDarkTheme});

  @override
  _GmailUIState createState() => _GmailUIState();
}

class _GmailUIState extends State<GmailUI> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Email> emails = [
    Email(sender: "Gamefound", subject: "New comment reply", content: "You have a new comment reply.", time: DateTime(2025, 6, 3, 10, 30)),
    Email(sender: "Gamefound", subject: "Update 24 in Lands of Evershade", content: "New update available.", time: DateTime(2025, 6, 3, 10, 15)),
    Email(sender: "BoardGameTables.com", subject: "A shipment from order #241222 is on the way", content: "Shipment details...", time: DateTime(2025, 6, 2, 14, 00), attachments: ["invoice.pdf"]),
    Email(sender: "Gamefound", subject: "AR Next: Coming to Gamefound in 2025", content: "Exciting news!", time: DateTime(2025, 6, 1, 9, 00), labels: ["Promotion"]),
  ];
  List<Email> drafts = [];
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;
  bool? hasAttachments;
  String? selectedLabel;
  List<String> labels = ["Work", "Personal", "Promotion"];
  bool autoReplyEnabled = false;
  String autoReplyMessage = "Thank you for your email. I am currently unavailable and will get back to you soon.";
  bool notificationsEnabled = true;

  void _searchEmails(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _applyAdvancedSearch({
    DateTime? newStartDate,
    DateTime? newEndDate,
    bool? newHasAttachments,
  }) {
    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasAttachments = newHasAttachments;
    });
  }

  void _onSend(Email email) {
    setState(() {
      emails.add(email);
      _showNewEmailNotification();
      _handleAutoReply(email);
    });
  }

  void _onSaveDraft(Email email) {
    setState(() {
      if (!drafts.any((draft) => draft.subject == email.subject && draft.content == email.content)) {
        drafts.add(email);
      }
    });
  }

  void _onUpdateEmail(Email updatedEmail) {
    setState(() {
      int index = emails.indexWhere((email) => email.subject == updatedEmail.subject && email.time == updatedEmail.time);
      if (index != -1) {
        emails[index] = updatedEmail;
      }
    });
  }

  void _showNewEmailNotification() {
    if (notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New Email: ${emails.last.sender} - ${emails.last.subject} at ${emails.last.time.toString().split('.')[0]}"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleAutoReply(Email receivedEmail) {
    if (autoReplyEnabled && !receivedEmail.sender.startsWith("You")) {
      Email autoReply = Email(
        sender: "You",
        subject: "Re: ${receivedEmail.subject}",
        content: autoReplyMessage,
        time: DateTime.now(),
        labels: ["AutoReply"],
      );
      setState(() {
        emails.add(autoReply);
        _showNewEmailNotification();
      });
    }
  }

  void _addLabel(String label) {
    setState(() {
      if (!labels.contains(label)) {
        labels.add(label);
      }
    });
  }

  void _removeLabel(String label) {
    setState(() {
      labels.remove(label);
      for (var email in emails) {
        if (email.labels.contains(label)) {
          _onUpdateEmail(email.copyWith(labels: email.labels.where((l) => l != label).toList()));
        }
      }
    });
  }

  void _renameLabel(String oldLabel, String newLabel) {
    setState(() {
      int index = labels.indexOf(oldLabel);
      if (index != -1 && !labels.contains(newLabel)) {
        labels[index] = newLabel;
        for (var email in emails) {
          if (email.labels.contains(oldLabel)) {
            var updatedLabels = email.labels.map((l) => l == oldLabel ? newLabel : l).toList();
            _onUpdateEmail(email.copyWith(labels: updatedLabels));
          }
        }
      }
    });
  }

  void _assignLabelToEmail(Email email, String label, bool add) {
    setState(() {
      if (add && !email.labels.contains(label)) {
        _onUpdateEmail(email.copyWith(labels: [...email.labels, label]));
      } else if (!add && email.labels.contains(label)) {
        _onUpdateEmail(email.copyWith(labels: email.labels.where((l) => l != label).toList()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          Email newEmail = Email(
            sender: "Test Sender",
            subject: "Test Email",
            content: "This is a test email.",
            time: DateTime.now(),
          );
          emails.insert(0, newEmail);
          _showNewEmailNotification();
          _handleAutoReply(newEmail);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Email> filteredEmails = emails.where((email) {
      bool matchesKeyword = !email.isInTrash && (
        email.sender.toLowerCase().contains(searchQuery.toLowerCase()) ||
        email.subject.toLowerCase().contains(searchQuery.toLowerCase()) ||
        email.content.toLowerCase().contains(searchQuery.toLowerCase())
      );

      bool matchesDate = true;
      if (startDate != null || endDate != null) {
        if (startDate != null && email.time.isBefore(startDate!)) matchesDate = false;
        if (endDate != null && email.time.isAfter(endDate!)) matchesDate = false;
      }

      bool matchesAttachments = true;
      if (hasAttachments != null) {
        matchesAttachments = (hasAttachments! && email.attachments.isNotEmpty) || (!hasAttachments! && email.attachments.isEmpty);
      }

      bool matchesLabel = true;
      if (selectedLabel != null && selectedLabel!.isNotEmpty) {
        matchesLabel = email.labels.contains(selectedLabel);
      }

      return matchesKeyword && matchesDate && matchesAttachments && matchesLabel;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        title: TextField(
          onChanged: _searchEmails,
          decoration: InputDecoration(
            hintText: "Search in mail",
            hintStyle: TextStyle(color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.black54),
            prefixIcon: Icon(Icons.search, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.black54),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Advanced Search"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text("Start Date"),
                        subtitle: Text(startDate != null ? startDate.toString().split(' ')[0] : "Not set"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _applyAdvancedSearch(newStartDate: picked);
                          }
                        },
                      ),
                      ListTile(
                        title: Text("End Date"),
                        subtitle: Text(endDate != null ? endDate.toString().split(' ')[0] : "Not set"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _applyAdvancedSearch(newEndDate: picked);
                          }
                        },
                      ),
                      CheckboxListTile(
                        title: Text("Has Attachments"),
                        value: hasAttachments ?? false,
                        onChanged: (value) {
                          _applyAdvancedSearch(newHasAttachments: value);
                          Navigator.pop(context);
                        },
                      ),
                      DropdownButton<String>(
                        hint: Text("Filter by Label"),
                        value: selectedLabel,
                        items: [null, ...labels].map((String? label) {
                          return DropdownMenuItem<String>(
                            value: label,
                            child: Text(label ?? "None"),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLabel = newValue;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _applyAdvancedSearch(newStartDate: null, newEndDate: null, newHasAttachments: null);
                        setState(() {
                          selectedLabel = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Clear"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Settings"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: Text("Enable Auto Reply"),
                        value: autoReplyEnabled,
                        onChanged: (value) {
                          setState(() {
                            autoReplyEnabled = value;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: "Auto Reply Message"),
                        controller: TextEditingController(text: autoReplyMessage),
                        onChanged: (value) {
                          setState(() {
                            autoReplyMessage = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text("Enable Notifications"),
                        value: notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SwitchListTile(
                        title: Text("Dark Theme"),
                        value: widget.isDarkTheme,
                        onChanged: (value) {
                          widget.onToggleTheme(value);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            MenuItem(icon: Icons.inbox, text: "All Inboxes"),
            MenuItem(icon: Icons.mail, text: "Primary"),
            MenuItem(icon: Icons.send, text: "Sent"),
            MenuItem(
              icon: Icons.drafts,
              text: "Drafts",
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Drafts"),
                      content: Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: drafts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(drafts[index].subject),
                              subtitle: Text(drafts[index].content),
                              onTap: () {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => ComposeEmailScreen(
                                    onSend: _onSend,
                                    onSaveDraft: _onSaveDraft,
                                    emailToReply: drafts[index],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            MenuItem(
              icon: Icons.delete,
              text: "Trash",
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Trash"),
                      content: Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: emails.where((email) => email.isInTrash).length,
                          itemBuilder: (context, index) {
                            final trashEmail = emails.where((email) => email.isInTrash).toList()[index];
                            return ListTile(
                              title: Text(trashEmail.subject),
                              subtitle: Text(trashEmail.content),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // MenuItem(icon: Icons.people, text: "Social"),
            // MenuItem(icon: Icons.local_offer, text: "Promotions"),
            // MenuItem(icon: Icons.update, text: "Updates"),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: filteredEmails.length,
        itemBuilder: (context, index) {
          final email = filteredEmails[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    email.sender[0],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(email.sender, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email.subject, style: TextStyle(color: Colors.grey[600])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(email.time.toString().split(' ')[0], style: TextStyle(color: Colors.grey[600])),
                    PopupMenuButton<String>(
                      onSelected: (String label) {
                        _assignLabelToEmail(email, label, !email.labels.contains(label));
                      },
                      itemBuilder: (BuildContext context) {
                        return labels.map((String label) {
                          return PopupMenuItem<String>(
                            value: label,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: email.labels.contains(label),
                                  onChanged: (bool? value) {
                                    _assignLabelToEmail(email, label, value ?? false);
                                    Navigator.pop(context);
                                  },
                                ),
                                Text(label),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ViewEmailScreen(
                      email: email,
                      onSend: _onSend,
                      onSaveDraft: _onSaveDraft,
                      onUpdateEmail: _onUpdateEmail,
                    ),
                  );
                },
              ),
              Divider(height: 1, thickness: 1),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor ?? Colors.white,
        child: Icon(Icons.create, color: Theme.of(context).floatingActionButtonTheme.foregroundColor ?? Colors.black87),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => ComposeEmailScreen(
              onSend: _onSend,
              onSaveDraft: _onSaveDraft,
            ),
          );
        },
      ),
    );
  }
}