import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final DataController dataController = Get.find<DataController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    dataController.getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getRecentChats() {
    final currentUserId = dataController.auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightgreen,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                  _buildRecentChatsSection(),
                  Expanded(
                    child: _buildMainContent(),
                  ),
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
              height: 100,
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
                    orElse: () =>
                        participants.isNotEmpty ? participants[0] : '',
                  );

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox(width: 60);
                      }

                      final user = userSnapshot.data!;
                      final userData =
                          user.data() as Map<String, dynamic>? ?? {};
                      final firstName = userData['first'] ?? '';
                      final lastName = userData['last'] ?? '';
                      final name = '$firstName $lastName'.trim();
                      final imageUrl = userData['image'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => ChatPage(
                                  chatId: chat.id,
                                  receiverName: name.isNotEmpty ? name : 'User',
                                  receiverId: otherUserId,
                                ));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.circle,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? Text(
                                        name.isNotEmpty
                                            ? name.substring(0, 1).toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                            color: AppColors.darkGreen),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  name.isNotEmpty ? name : 'User',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (!_hasSearched || _searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for users to message',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    final filteredUsers = dataController.filteredUsers.where((user) {
      final data = user.data() as Map<String, dynamic>? ?? {};
      final first = (data['first'] ?? '').toString().toLowerCase();
      final last = (data['last'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      return first.contains(_searchQuery.toLowerCase()) ||
          last.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No user found matching "$_searchQuery"',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final userId = user.id;
        final currentUserId = dataController.auth.currentUser?.uid;

        if (userId == currentUserId) return const SizedBox();

        return _buildUserTile(user);
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
            _hasSearched = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildUserTile(DocumentSnapshot user) {
    final userData = user.data() as Map<String, dynamic>? ?? {};
    final imageUrl = userData['image'] as String? ?? '';
    final firstName = userData['first'] as String? ?? '';
    final lastName = userData['last'] as String? ?? '';
    final email = userData['email'] as String? ?? '';
    final role = userData['role'] as String? ?? '';

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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (email.isNotEmpty)
            Text(
              email,
              style: TextStyle(color: AppColors.grey),
            ),
          if (role.isNotEmpty)
            Text(
              role,
              style: TextStyle(
                color: AppColors.lightgreen,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.message, color: AppColors.darkGreen),
        onPressed: () => _openChat(user),
      ),
    );
  }

  void _openChat(DocumentSnapshot user) async {
    final currentUser = dataController.auth.currentUser;
    if (currentUser == null) return;

    final userId = user.id;
    final currentUserId = currentUser.uid;

    // Create sorted chat ID
    final groupId = [userId, currentUserId]..sort();
    final chatId = groupId.join('-');

    // Create chat document if it doesn't exist
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'participants': [userId, currentUserId],
        'createdAt': Timestamp.now(),
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': currentUserId,
      });
    }

    // Navigate to chat page
    Get.to(() => ChatPage(
          chatId: chatId,
          receiverName:
              '${user.get('first') ?? 'User'} ${user.get('last') ?? ''}'.trim(),
          receiverId: userId,
        ));
  }
}
