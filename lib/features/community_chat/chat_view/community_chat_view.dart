import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:voter_multi_app/custom/const.dart';
import 'package:voter_multi_app/features/community_chat/calls_view/calls_view.dart';
import 'package:voter_multi_app/features/community_chat/chat_view/more_info_person.dart';
import 'package:voter_multi_app/features/community_chat/updates_view/updates_view.dart';
class CommunityChatView extends StatefulWidget {
  const CommunityChatView({super.key});

  @override
  _CommunityChatViewState createState() => _CommunityChatViewState();
}

class _CommunityChatViewState extends State<CommunityChatView> {
  late IO.Socket socket;
  Map<String, dynamic>? _profileData;
  String? _userId;
  String? _phoneMember;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> chatSessions = [];
  int _currentIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _searchResult;
  List<Map<String, dynamic>> previousChatUsers = [];

  bool _isSearching = false;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchProfileData() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];

          if (userData.containsKey('member_phone') &&
              userData.containsKey('user_id')) {
            setState(() {
              _profileData = userData;
              _userId = userData['user_id'].toString();
              _phoneMember = userData['member_phone'].toString();
            });
          } else {
            throw Exception(
                'User data does not contain member_phone or user_id key');
          }
        } else {
          throw Exception(
              'API Response does not contain user key or is not a Map');
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _initSocket() {
    socket = IO.io('http://190.92.175.165:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      if (_phoneMember != null) {
        socket.emit('join', _phoneMember);
      } else {}
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add({
          'text': data['text'],
          'sender': data['sender'],
          'name': data['name'],
          'profile_image': data['profile_image'],
        });

        int index =
            chatSessions.indexWhere((chat) => chat['sender'] == data['sender']);
        if (index >= 0) {
          chatSessions[index] = {
            'sender': data['sender'],
            'name': data['name'],
            'profile_image': data['profile_image'],
            'last_message': data['text'],
          };
        } else {
          chatSessions.add({
            'sender': data['sender'],
            'name': data['name'],
            'profile_image': data['profile_image'],
            'last_message': data['text'],
          });
        }
      });
    });

    socket.on('disconnect', (_) => print('Disconnected from socket'));
  }

  Future<void> _searchUsers(String number) async {
    try {
      final response = await http.get(
        Uri.parse('http://190.92.175.165:3000/chat_search/$number'),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          setState(() {
            _searchResult = responseData['user'];
          });
        } else {}
      } else {}
    } catch (e) {}
  }

  Future<void> _fetchPreviousChatUsers() async {
    try {
      final response = await http.post(
        Uri.parse('http://190.92.175.165:3000/api/previousChatUsers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "number": _phoneMember
        }), // Send the user's phone number to the API
      );

      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        setState(() {
          previousChatUsers = users.map((user) {
            return {
              'name': user['name'],
              'member_phone': user['member_phone'],
              'profile_image': user['profile_image'],
            };
          }).toList();
        });
      } else {}
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData().then((_) {
      if (_phoneMember != null) {
        _initSocket();
        _fetchPreviousChatUsers();
      } else {}
    });
  }

  void _onPreviousUserTap(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          recipientName: user['name'] ?? 'Unknown Name',
          recipientPhone: user['member_phone'] ?? '',
          recipientImage: "${ConstRes.imageUrl}${user['profile_image']}",
          senderPhone: _phoneMember ?? '',
          recipientProfileImage: "${ConstRes.imageUrl}${user['profile_image']}",
        ),
      ),
    );
  }

  Widget _buildCommunityChatView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          if (_isSearching && _searchResult != null)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: _searchResult!['profile_image'] != null &&
                        _searchResult!['profile_image'].isNotEmpty
                    ? NetworkImage(
                        "${ConstRes.imageUrl}${_searchResult!['profile_image']}")
                    : const AssetImage('asset/images/placeholder.png')
                        as ImageProvider,
              ),
              title: Text(_searchResult!['name'] ?? 'Unknown Name'),
              subtitle: Text(_searchResult!['member_phone'] ?? 'Unknown Phone'),
              onTap: () {
                // Handle tap on search result
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      recipientName: _searchResult!['name'] ?? 'Unknown Name',
                      recipientPhone: _searchResult!['member_phone'] ?? '',
                      recipientImage:
                          "${ConstRes.imageUrl}${_searchResult!['profile_image']}",
                      senderPhone: _phoneMember ?? '',
                      recipientProfileImage:
                          "${ConstRes.imageUrl}${_searchResult!['profile_image']}",
                    ),
                  ),
                );
              },
            ),
          // Display previous chat users

          Expanded(
            child: ListView.builder(
              itemCount: previousChatUsers.length,
              itemBuilder: (context, index) {
                var user = previousChatUsers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(),
                    ),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: AlertDialog(
                                        backgroundColor: Colors.transparent,
                                        contentPadding: EdgeInsets.zero,
                                        content: SizedBox(
                                          child: Image(
                                            image: user['profile_image'] != null && user['profile_image'].isNotEmpty
                                                ? NetworkImage("${ConstRes.imageUrl}${user['profile_image']}")
                                                : const AssetImage('asset/images/placeholder.png') as ImageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: user['profile_image'] != null && user['profile_image'].isNotEmpty
                                    ? NetworkImage("${ConstRes.imageUrl}${user['profile_image']}")
                                    : const AssetImage('asset/images/placeholder.png') as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'Unknown Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user['member_phone'] ?? 'Unknown Phone',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _onPreviousUserTap(user),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildCommunityChatView(),
      const UpdatesView(),
      const CallsView(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by phone number',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                onSubmitted: (query) {
                  if (_searchController.text.isNotEmpty) {
                    _searchUsers(_searchController.text);
                  }
                },
              )
            : const Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchResult = null;
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: const Color(0xffa0cf1a),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}







class ChatDetailPage extends StatefulWidget {
  final String recipientName;
  final String recipientPhone;
  final String recipientImage;
  final String senderPhone;
  final String recipientProfileImage;

  const ChatDetailPage({
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientImage,
    required this.senderPhone,
    required this.recipientProfileImage,
    super.key,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchPreviousMessages();
    _initSocket();
  }

  Future<void> _fetchPreviousMessages() async {
    try {
      final response = await http.post(
        Uri.parse('http://190.92.175.165:3000/api/getMessages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "sender_id": widget.senderPhone,
          "receiver_id": widget.recipientPhone,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> previousMessages = json.decode(response.body);
        setState(() {
          messages = previousMessages.map((msg) {
            return {
              'text': msg['message'],
              'sender': msg['sender_id'],
              'receiver': msg['receiver_id'],
              'status': msg['status'] ?? 'sent', // Default status as 'sent'
            };
          }).toList();
        });
        _scrollToBottom();
      } else {}
    } catch (e) {}
  }

  void _initSocket() {
    socket = IO.io('http://190.92.175.165:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      socket.emit('join', widget.senderPhone);
    });

    // Handle incoming messages
    socket.on('receiveMessage${widget.senderPhone}${widget.recipientPhone}',
        (data) {
      setState(() {
        messages.add({
          'text': data['text'] ?? 'No text',
          'sender': data['sender'] ?? 'Unknown Sender',
          'status': data['status'] ?? 'sent', // Default status as 'sent'
        });
      });
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = {
        'sender': widget.senderPhone,
        'recipient': widget.recipientPhone,
        'text': text,
        'status': 'sent',
      };

      socket.emit('sendMessage', newMessage);

      setState(() {
        messages.add(newMessage);
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0, // Scroll to the bottom (since the list is reversed)
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'sent') {
      return const Icon(Icons.done_all,
          size: 16, color: Colors.grey);
    } else if (status == 'delivered') {
      return const Icon(Icons.done_all,
          size: 16, color: Colors.grey);
    } else if (status == 'read') {
      return const Icon(Icons.done_all,
          size: 16, color: Colors.blue);
    }
    return const SizedBox.shrink();
  }

  void _openAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 250,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.doc),
                  title: const Text('Document'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle document selection here
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      // Handle image from camera
                      // _sendImage(File(pickedFile.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      // Handle image from gallery
                      // _sendImage(File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    socket.off('receiveMessage${widget.senderPhone}${widget.recipientPhone}');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffcef0b6),
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoreInfoPerson(
                  recipientName: widget.recipientName,
                  recipientImage: widget.recipientProfileImage,
                  recipientPhone: widget.recipientPhone,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.recipientImage.isNotEmpty
                    ? NetworkImage(widget.recipientImage)
                    : const AssetImage('assets/images/placeholder.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 10),
              Text(
                widget.recipientName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),

        actions: [
          InkWell(
            onTap: () {
              showMenu(
                color: Colors.white,
                context: context,
                position: const RelativeRect.fromLTRB(
                    100, 80, 0, 0),
                items: [
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Block'),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Mute Notification'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('More'),
                  ),
                ],
              ).then((value) {
                if (value == 1) {
                } else if (value == 2) {}
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[messages.length - 1 - index]['sender'] ==
                    widget.senderPhone;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      constraints: BoxConstraints(

                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xffDCF8C6)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                          bottomLeft: isMe
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomRight: isMe
                              ? const Radius.circular(0)
                              : const Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            messages[messages.length - 1 - index]['text'],
                            style: TextStyle(
                              color: isMe ? Colors.black : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(
                                height:
                                    5),
                            _buildStatusIcon(
                                messages[messages.length - 1 - index]
                                    ['status']),
                          ],
                        ],
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.paperclip,
                                  color: Color(0xffa0cf1a)),
                              onPressed: _openAttachmentOptions,
                            ),
                            IconButton(
                              icon: const Icon(Icons.send,
                                  color: Color(0xffa0cf1a)),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
