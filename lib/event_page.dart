
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
class EventPageView extends StatefulWidget {


  DocumentSnapshot eventData,user;

  EventPageView(this.eventData,this.user, {super.key});




  @override
  _EventPageViewState createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {


  DataController dataController = Get.find<DataController>();


  List eventSavedByUsers = [];

  @override
  Widget build(BuildContext context) {



    String image = '';

    try{
      image = widget.user.get('image');
    }catch(e){
      image = '';
    }

    String eventImage = '';
    try{
      List media = widget.eventData.get('media') as List;
      Map mediaItem = media.firstWhere((element) => element['isImage'] == true) as Map;
      eventImage = mediaItem['url'];
    }catch(e){
      eventImage = '';
    }


    List joinedUsers = [];

    try{
      joinedUsers = widget.eventData.get('joined');
    }catch(e){
      joinedUsers = [];
    }

    List tags = [];
    try{
      tags = widget.eventData.get('tags');
    }catch(e){
      tags = [];
    }

    String tagsCollectively = '';

    for (var e in tags) {
      tagsCollectively += '#$e ';
    }

    int likes = 0;
    int comments = 0;

    try{
      likes = widget.eventData.get('likes').length;
    }catch(e){
      likes = 0;
    }

    try{
      comments = widget.eventData.get('comments').length;
    }catch(e){
      comments = 0;
    }


    try{
      eventSavedByUsers = widget.eventData.get('saves');
    }catch(e){
      eventSavedByUsers = [];
    }

    // DateTime d = DateTime.tryParse(widget.eventData.get('date'))!;

    // String formattedDate = formatDate(widget.eventData.get('date'));
    //DateFormat("dd-MMM").format(d);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 20),
                  width: 30,
                  height: 30,
                  child: Image.asset(
                    'assets/Header.png',
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      image,
                    ),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user.get('first')} ${widget.user.get('last')}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        "${widget.user.get('location')}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Text(
                          '${widget.eventData.get('event')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xff0000FF), width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Text(
                      '${widget.eventData.get('start_time')}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${widget.eventData.get('event_name')}",
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${widget.eventData.get('date')}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/location.png',
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${widget.eventData.get('location')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(eventImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  children: [


                    SizedBox(
                      width: Get.width*0.6,
                      height: 50,
                      child: ListView.builder(itemBuilder: (ctx,index){


                        DocumentSnapshot user = dataController.allUsers.firstWhere((e)=> e.id == joinedUsers[index]);

                        String image = '';

                        try{
                          image = user.get('image');
                        }catch(e){
                          image = '';
                        }



                        return Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            minRadius: 13,
                            backgroundImage: NetworkImage(image),
                          ),
                        );
                      },itemCount: joinedUsers.length,scrollDirection: Axis.horizontal,),
                    ),


                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$4${widget.eventData.get('fee')}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "\$4${widget.eventData.get('fee')}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "${widget.eventData.get('max_entries')} spots left!",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(children: [

                    TextSpan(
                      text: widget.eventData.get('description'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  ])),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                      //  Get.to(() => const Inviteguest());
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.blue.withOpacity(0.9)),
                        child: const Center(
                          child: Text(
                            "invite Friends",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                       // Get.off(() => CheckOutView(widget.eventData));
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 0.1,
                                blurRadius: 60,
                                offset:
                                const Offset(0, 1), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(13)),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: const Center(
                          child: Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tagsCollectively,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset('assets/heart.png'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    likes.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/message.png',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    comments.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/send.png',
                    height: 16,
                    width: 16,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: (){

                      if(eventSavedByUsers.contains(FirebaseAuth.instance.currentUser!.uid)){

                        FirebaseFirestore.instance.collection('events').doc(widget.eventData.id).set({
                          'saves': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
                        },SetOptions(merge: true));



                        eventSavedByUsers.remove(FirebaseAuth.instance.currentUser!.uid);
                        setState(() {

                        });

                      }else{
                        FirebaseFirestore.instance.collection('events').doc(widget.eventData.id).set({
                          'saves': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
                        },SetOptions(merge: true));
                        eventSavedByUsers.add(FirebaseAuth.instance.currentUser!.uid);
                        setState(() {

                        });
                      }
                    },
                    child: Image.asset(
                      'assets/boomMark.png',
                      height: 16,
                      width: 16,
                      color: eventSavedByUsers.contains(FirebaseAuth.instance.currentUser!.uid)? Colors.red : Colors.black,

                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),

            ],
          ),
        ),
      ),
    );
  }
}