import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final DataController dataController = Get.find<DataController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    dataController.getUsers(); // Load users initially
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // In MessagesPage.dart, update the getRecentChats method:
  Stream<QuerySnapshot> getRecentChats() {
    final currentUserId = dataController.auth.currentUser?.uid;
    if (currentUserId == null) return const Stream<QuerySnapshot>.empty();

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightgreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (dataController.isUsersLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                //  _buildRecentChatsSection(),
                  _buildMessagesListSection(), // Add this new section
                  Expanded(child: _buildMainContent()),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentChatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: getRecentChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final chats = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recent chats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final participants = List<String>.from(chat['participants']);
                  final currentUserId = dataController.auth.currentUser?.uid;
                  final otherUserId = participants.firstWhere(
                        (id) => id != currentUserId,
                    orElse: () => '',
                  );

                  return _buildChatAvatar(chat, otherUserId);
                },
              ),
            ),
            const Divider(height: 20),
          ],
        );
      },
    );
  }


// In MessagesPage.dart, update the _buildChatAvatar method:
  Widget _buildChatAvatar(DocumentSnapshot chat, String otherUserId) {
    if (otherUserId.isEmpty) return const SizedBox(width: 60);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox(width: 60);

        final user = userSnapshot.data!;
        final userData = user.data() as Map<String, dynamic>? ?? {};
        final firstName = userData['first'] ?? '';
        final lastName = userData['last'] ?? '';
        final name = '$firstName $lastName'.trim();
        final imageUrl = userData['image'] ?? '';
        final lastMessage = chat['lastMessage'] ?? '';
        final lastMessageTime = (chat['lastMessageTime'] as Timestamp?)?.toDate();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () {
              final receiverId = user.id;
              final receiverName = name;
              final currentUserId = dataController.auth.currentUser!.uid;
              final groupId = [currentUserId, receiverId]..sort();
              final chatId = groupId.join('-');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    chatId: chatId,
                    receiverId: receiverId,
                    receiverName: receiverName,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.circle,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(color: AppColors.darkGreen),
                  )
                      : null,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'User',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (lastMessage.isNotEmpty)
                        Text(
                          lastMessage,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (_searchQuery.isEmpty) {
      return StreamBuilder<QuerySnapshot>(
        stream: getRecentChats(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return const SizedBox(); // Don't show the text if messages exist
          } else {
            return const Center(child: Text('Start typing to search for users'));
          }
        },
      );
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final query = _searchQuery.toLowerCase();
        final matchedUsers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final first = (data['first'] ?? '').toString().toLowerCase();
          final last = (data['last'] ?? '').toString().toLowerCase();
          final fullName = '$first $last';
          return first.contains(query) || last.contains(query) || fullName.contains(query);
        }).toList();

        if (matchedUsers.isEmpty) {
          return const Center(child: Text('No matching users found'));
        }

        return ListView.builder(
          itemCount: matchedUsers.length,
          itemBuilder: (context, index) {
            final user = matchedUsers[index];
            return _buildUserTile(user);
          },
        );
      },
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for people...',
          prefixIcon: Icon(Icons.search, color: AppColors.grey),
          filled: true,
          fillColor: AppColors.textFieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _hasSearched = value.trim().isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildUserTile(DocumentSnapshot user) {
    final userData = user.data() as Map<String, dynamic>? ?? {};
    final imageUrl = userData['image'] ?? '';
    final firstName = userData['first'] ?? '';
    final lastName = userData['last'] ?? '';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.circle,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty
            ? Text(
          '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
          style: TextStyle(color: AppColors.darkGreen),
        )
            : null,
      ),
      title: Text(
        [firstName, lastName]
            .where((s) => s.isNotEmpty)
            .join(' ')
            .trim()
            .isNotEmpty
            ? [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim()
            : 'Unnamed User',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (email.isNotEmpty)
            Text(email, style: TextStyle(color: AppColors.grey)),
          if (role.isNotEmpty)
            Text(role,
                style: TextStyle(color: AppColors.lightgreen, fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.message, color: AppColors.darkGreen),
        onPressed: () => _openChat(user),
      ),
    );
  }

  Widget _buildMessagesListSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: getRecentChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator())
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final chats = snapshot.data!.docs;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Your Messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final participants = List<String>.from(chat['participants']);
                    final currentUserId = dataController.auth.currentUser?.uid;
                    final otherUserId = participants.firstWhere(
                          (id) => id != currentUserId,
                      orElse: () => '',
                    );

                    return _buildMessageListItem(chat, otherUserId);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildMessageListItem(DocumentSnapshot chat, String otherUserId) {
    if (otherUserId.isEmpty) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox();

        final user = userSnapshot.data!;
        final userData = user.data() as Map<String, dynamic>? ?? {};
        final firstName = userData['first'] ?? '';
        final lastName = userData['last'] ?? '';
        final name = '$firstName $lastName'.trim();
        final imageUrl = userData['image'] ?? '';
        final lastMessage = chat['lastMessage'] ?? '';
        final lastMessageTime = (chat['lastMessageTime'] as Timestamp?)?.toDate();
        final isRead = chat['lastMessageSender'] != otherUserId;

        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.circle,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(color: AppColors.darkGreen),
            )
                : null,
          ),
          title: Text(
            name.isNotEmpty ? name : 'User',
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(
            lastMessage,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          trailing: Text(
            _formatMessageTime(lastMessageTime ?? DateTime.now()),
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
          onTap: () {
            final receiverId = user.id;
            final receiverName = name;
            final currentUserId = dataController.auth.currentUser!.uid;
            final groupId = [currentUserId, receiverId]..sort();
            final chatId = groupId.join('-');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  chatId: chatId,
                  receiverId: receiverId,
                  receiverName: receiverName,
                ),
              ),
            );
          },
        );
      },
    );
  }
  String _formatMessageTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
  void _openChat(DocumentSnapshot user) async {
    try {
      final currentUser = dataController.auth.currentUser;
      if (currentUser == null) {
        print('No current user');
        return;
      }

      final userId = user.id;
      final currentUserId = currentUser.uid;

      if (userId.isEmpty || currentUserId.isEmpty) {
        print('Invalid user IDs');
        return;
      }

      print('Opening chat between $currentUserId and $userId');

      final groupId = [userId, currentUserId]..sort();
      final chatId = groupId.join('-');

      print('Chat ID: $chatId');

      final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
      final chatSnapshot = await chatDoc.get();

      if (!chatSnapshot.exists) {
        print('Creating new chat document');
        await chatDoc.set({
          'chatId': chatId,
          'participants': [userId, currentUserId],
          'createdAt': Timestamp.now(),
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
          'lastMessageSender': currentUserId,
        });
      }

      final receiverName =
      '${user.get('first') ?? 'User'} ${user.get('last') ?? ''}'.trim();
      print('Navigating to chat with $receiverName');

      Get.to(() => ChatPage(
        chatId: chatId,
        receiverName: receiverName,
        receiverId: userId,
      ));
    } catch (e) {
      print('Error opening chat: $e');
      Get.snackbar('Error', 'Could not open chat: ${e.toString()}');
    }
  }

}
