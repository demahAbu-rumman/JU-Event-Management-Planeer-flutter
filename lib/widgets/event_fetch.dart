import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';

import '../util/app_color.dart';

// Sample images to use as fallback or placeholders
List<String> imageList = [
  'assets/#1.png',
  'assets/#2.png',
  'assets/#3.png',
  'assets/#1.png',
];

// Widget to fetch and display the events
Future<Widget> EventsFeed() async {
  DataController dataController = Get.find<DataController>();

  return Obx(() => dataController.isEventsLoading.value
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (ctx, i) {
      return EventItem(dataController.allEvents[i]);
    },
    itemCount: dataController.allEvents.length,
  ));
}

// Card builder for displaying events
/*Widget buildCard({String? image, String? text, Function? func, DocumentSnapshot? eventData}) {
  DataController dataController = Get.find<DataController>();

  List joinedUsers = (eventData?.get('joined') ?? []).cast<String>();
  List<String> dateInformation = (eventData?.get('date')?.toString().split('-') ?? []);
  int comments = (eventData?.get('comments') as List?)?.length ?? 0;
  List userLikes = (eventData?.get('likes') ?? []).cast<String>();
  List eventSavedByUsers = (eventData?.get('saves') ?? []).cast<String>();

  return Container(
    padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: const Color(0x000602d3).withOpacity(0.15),
          spreadRadius: 0.1,
          blurRadius: 2,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            func?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              image: image != null && image.isNotEmpty
                  ? DecorationImage(image: NetworkImage(image), fit: BoxFit.fill)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            height: Get.width * 0.5,
            child: image == null || image.isEmpty
                ? const Center(child: Text('No Image Available'))
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: 41,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xffADD8E6)),
                ),
                child: Text(
                  '${dateInformation.isNotEmpty ? dateInformation[0] : ''}-${dateInformation.length > 1 ? dateInformation[1] : ''}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(text ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              ),
              InkWell(
                onTap: () {
                  if (eventSavedByUsers.contains(FirebaseAuth.instance.currentUser!.uid)) {
                    FirebaseFirestore.instance.collection('events').doc(eventData!.id).update({
                      'saves': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
                    });
                  } else {
                    FirebaseFirestore.instance.collection('events').doc(eventData!.id).update({
                      'saves': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
                    });
                  }
                },
                child: SizedBox(
                  width: 16,
                  height: 19,
                  child: Image.assets(
                    'assets/boomMark.png',
                    fit: BoxFit.contain,
                    color: eventSavedByUsers.contains(FirebaseAuth.instance.currentUser!.uid)
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Display joined users
        if (joinedUsers.isNotEmpty)
          Row(
            children: [
              SizedBox(
                width: Get.width * 0.6,
                height: 50,
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    try {
                      DocumentSnapshot user = dataController.allUsers.firstWhere((e) => e.id == joinedUsers[index]);
                      String image = user.get('image') ?? '';

                      return Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: CircleAvatar(
                          minRadius: 13,
                          backgroundImage: NetworkImage(image),
                        ),
                      );
                    } catch (e) {
                      return Container();
                    }
                  },
                  itemCount: joinedUsers.length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          ),
        const SizedBox(height: 15),
        Row(
          children: [
            const SizedBox(width: 68),
            InkWell(
              onTap: () {
                if (userLikes.contains(FirebaseAuth.instance.currentUser!.uid)) {
                  FirebaseFirestore.instance.collection('events').doc(eventData!.id).update({
                    'likes': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
                  });
                } else {
                  FirebaseFirestore.instance.collection('events').doc(eventData!.id).update({
                    'likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
                  });
                }
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xffD24698).withOpacity(0.02))],
                ),
                child: Icon(Icons.favorite,
                    size: 14, color: userLikes.contains(FirebaseAuth.instance.currentUser!.uid) ? Colors.red : Colors.black),
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '${userLikes.length}',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(0.5),
              width: 17,
              height: 17,
              child: Image.assets(
                'assets/message.png',
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$comments',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.all(0.5),
              width: 16,
              height: 16,
              child: Image.assets(
                'assets/send.png',
                fit: BoxFit.contain,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

*/

// Function for individual event item
Widget EventItem(DocumentSnapshot event) {
  DataController dataController = Get.find<DataController>();
  String userImage = '';
  String eventImage = '';

  try {
    DocumentSnapshot user = dataController.allUsers.firstWhere((e) => event.get('uid') == e.id);
    userImage = user.get('image') ?? '';
  } catch (e) {
    userImage = '';
  }

  try {
    List media = event.get('media') as List;
    Map? mediaItem = media.firstWhere((element) => element['isImage'] == true, orElse: () => null);
    eventImage = mediaItem != null ? mediaItem['url'] : '';
  } catch (e) {
    eventImage = '';
  }

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Event Name & Notification Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.event, color: Colors.lightGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.get('event_name'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Notification Badge (Right Side)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightgreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.get('location') ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Event Image
          if (eventImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                eventImage,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    ),
  );
}









