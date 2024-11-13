import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CallsView extends StatefulWidget {
  const CallsView({super.key});

  @override
  State<CallsView> createState() => _CallsViewState();
}

class _CallsViewState extends State<CallsView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Coming Soon.... ",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

















// class CommunityChatView extends StatefulWidget {
//   const CommunityChatView({super.key});
//
//   @override
//   State<CommunityChatView> createState() => _CommunityChatViewState();
// }
//
// class _CommunityChatViewState extends State<CommunityChatView> {
//   late IO.Socket socket;
//   Map<String, dynamic>? _profileData;
//   String? _userId;
//   String? _phoneMember;
//   String? _selectedRecipientPhone;
//   List<Map<String, dynamic>> messages = [];
//
//   TextEditingController _messageController = TextEditingController();
//   TextEditingController _searchController = TextEditingController();
//   Map<String, dynamic>? _searchResult;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData().then((_) {
//       if (_phoneMember != null) {
//         _initSocket();
//       } else {
//         print('phone_member is null. Cannot initialize socket.');
//       }
//     });
//   }
//
//   Future<String?> getToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//
//   Future<void> _fetchProfileData() async {
//     try {
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://vote.nextgex.com/api/user'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         print('API Response Data: $responseData');
//
//         if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
//           var userData = responseData['user'];
//           print('User Data: $userData');
//
//           if (userData.containsKey('member_phone') && userData.containsKey('user_id')) {
//             setState(() {
//               _profileData = userData;
//               _userId = userData['user_id'].toString();
//               _phoneMember = userData['member_phone'].toString();
//             });
//           } else {
//             print('User data does not contain member_phone or user_id key');
//             throw Exception('User data does not contain member_phone or user_id key');
//           }
//         } else {
//           print('API Response does not contain user key or is not a Map');
//           throw Exception('API Response does not contain user key or is not a Map');
//         }
//       } else {
//         print('Failed to load profile data. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         throw Exception('Failed to load profile data');
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//   void _initSocket() {
//     socket = IO.io('http://3.108.237.102:4000', <String, dynamic>{
//       'transports': ['websocket'],
//     });
//
//     socket.on('connect', (_) {
//       print('Connected to socket');
//       if (_phoneMember != null) {
//         socket.emit('join', _phoneMember);
//       } else {
//         print('phone_member is null. Cannot emit join event.');
//       }
//     });
//
//     socket.on('receiveMessage', (data) {
//       print('Received message from ${data['sender']}');
//       print('Message: ${data['text']}');
//
//       setState(() {
//         messages.add({
//           'text': data['text'],
//           'sender': data['sender'],
//         });
//       });
//     });
//
//     socket.on('disconnect', (_) => print('Disconnected from socket'));
//   }
//
//
//
//
//   Future<void> _searchUsers(String number) async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://3.108.237.102:4000/chat_search/$number'),
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//
//         if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
//           setState(() {
//             _searchResult = responseData['user'];
//           });
//         } else {
//           print('Unexpected API response format');
//         }
//       } else {
//         print('Failed to search users. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xffa0cf1a),
//         title: Text(
//           "Community Chats",
//           style: GoogleFonts.habibi(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search by phone number',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     if (_searchController.text.isNotEmpty) {
//                       _searchUsers(_searchController.text);
//                     }
//                   },
//                 ),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           if (_searchResult != null)
//             ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: _searchResult!['profile_image'] != null && _searchResult!['profile_image'].isNotEmpty
//                     ? NetworkImage("${ConstRes.imageUrl}${_searchResult!['profile_image']}")
//                     : const AssetImage('asset/images/placeholder.png') as ImageProvider,
//               ),
//               title: Text(_searchResult!['name'] ?? 'Unknown Name'),
//               subtitle: Text(_searchResult!['member_phone'] ?? 'Unknown Phone'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatDetailPage(
//                       recipientName: _searchResult!['name'] ?? 'Unknown Name',
//                       recipientPhone: _searchResult!['member_phone'] ?? '',
//                       recipientImage: "${ConstRes.imageUrl}${_searchResult!['profile_image']}",
//                       senderPhone: _phoneMember ?? '',
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     socket.dispose();
//     _messageController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }
//
//
//
// class ChatDetailPage extends StatefulWidget {
//   final String recipientName;
//   final String recipientPhone;
//   final String recipientImage;
//   final String senderPhone;
//
//   const ChatDetailPage({
//     required this.recipientName,
//     required this.recipientPhone,
//     required this.recipientImage,
//     required this.senderPhone,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<ChatDetailPage> createState() => _ChatDetailPageState();
// }
//
// class _ChatDetailPageState extends State<ChatDetailPage> {
//   late IO.Socket socket;
//   List<Map<String, dynamic>> messages = [];
//   TextEditingController _messageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _initSocket();
//   }
//
//   void _initSocket() {
//     socket = IO.io('http://3.108.237.102:4000', <String, dynamic>{
//       'transports': ['websocket'],
//     });
//
//     socket.on('connect', (_) {
//       print('Connected to socket');
//       socket.emit('join', widget.senderPhone);
//     });
//
//     // socket.on('receiveMessage', (data) {
//     //   setState(() {
//     //     messages.add({
//     //       'text': data['text'],
//     //       'sender': data['sender'],
//     //     });
//     //   });
//     // });
//
//         socket.on('receiveMessage', (data) {
//       print('Received message from ${data['sender']}');
//       print('Message: ${data['text']}');
//       print('Message: ${data['name']}');
//       print('Message: ${data['profile_image']}');
//
//       setState(() {
//         messages.add({
//           'text': data['text'],
//           'sender': data['sender'],
//           'name': data['name'],
//           'profile_image' : data['profile_image'],
//         });
//       });
//     });
//
//
//     socket.on('disconnect', (_) => print('Disconnected from socket'));
//   }
//
//   void _sendMessage() {
//     String text = _messageController.text.trim();
//     if (text.isNotEmpty) {
//       socket.emit('sendMessage', {
//         'sender': widget.senderPhone,
//         'recipient': widget.recipientPhone,
//         'text': text,
//       });
//       setState(() {
//         messages.add({
//           'text': text,
//           'sender': widget.senderPhone,
//         });
//         _messageController.clear();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     socket.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xffa0cf1a),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.recipientImage.isNotEmpty
//                   ? NetworkImage(widget.recipientImage)
//                   : AssetImage('asset/images/placeholder.png') as ImageProvider,
//             ),
//             const SizedBox(width: 10),
//             Text(
//               widget.recipientName,
//               style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 bool isMe = messages[index]['sender'] == widget.senderPhone;
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isMe ? const Color(0xffa0cf1a) : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       messages[index]['text'],
//                       style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }