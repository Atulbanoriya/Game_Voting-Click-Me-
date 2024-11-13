import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../custom/notification_helper/notification_helper.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, String?>> notifications =
    NotificationService.getNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.aBeeZee(),
        ),
        backgroundColor: const Color(0xffa0cf1a),
      ),
      body: notifications.isEmpty
          ?  Center(child: Text(
          'No notifications',
        style: GoogleFonts.k2d(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ))
          : RefreshIndicator(
        onRefresh: () async {
          setState(() {
            notifications = NotificationService.getNotifications(); // Refresh notifications
          });
        },
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final title = notification['title'] ?? 'No Title';
            final body = notification['body'] ?? 'No Body';
            final date = DateTime.now();

            return Card(
              color: Colors.white,
              margin:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffa0cf1a),
                  child: Icon(
                    CupertinoIcons.bell_fill,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  _formatDate(date),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: Text(
                      body,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getFormattedTime(date)} on ${_getFormattedDate(date)}';
  }

  String _getFormattedTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hours:$minutes $period';
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

