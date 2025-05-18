import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';

import '../util/app_color.dart';

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
                  event.get('eventName'),
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

         /// Event Time
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${event.get('start_time') ?? 'N/A'} - ${event.get('end_time') ?? 'N/A'}",
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









