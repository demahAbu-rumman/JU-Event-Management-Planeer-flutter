import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //TextEditingController role = TextEditingController();
 // TextEditingController descriptionController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool _isOpen = false;

  late PanelController _panelController = PanelController();
  var _imageList = [
    'lib/assets/eventsPic1.jpg',
    'lib/assets/eventsPic2.jpg',
    'lib/assets/eventsPic3.jpg',
    'lib/assets/eventsPic4.jpg',
    'lib/assets/eventsPic5.jpg',
    'lib/assets/eventPic6.jpg',
    'lib/assets/eventPic7.jpg',
    'lib/assets/eventPic8.jpg',
    'lib/assets/eventPic9.jpg',
    'lib/assets/eventPic10.jpg',
    'lib/assets/eventPic11.jpg',
    'lib/assets/eventPicc12.jpg',
    'lib/assets/eventPic13.jpg',
    'lib/assets/eventPic14.jpg',
    'lib/assets/eventPic15.jpg',
    'lib/assets/eventPic16.jpg',
  ];
  bool isNotEditable = true;
  DataController? dataController;
  String image = '';
  String? selectedRole; // Add this variable to hold the selected role


  @override
  initState(){
    super.initState();
    dataController = Get.find<DataController>();

    firstNameController.text = dataController!.myDocument!.get('first');
    lastNameController.text = dataController!.myDocument!.get('last');

    try{
      image = dataController!.myDocument!.get('image');
    }catch(e){
      image = '';
    }

    try {
      selectedRole = dataController!.myDocument!.get('role');
    } catch (e) {
      selectedRole = 'Role not set'; // Default value if no role is fetched
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,  // Remove AppBar shadow for a cleaner look
      ),
      body:
      Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: 0.7,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/profilePic.png'),
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.3,
            child: Container(
              color: Colors.white,
            ),
          ),
          SlidingUpPanel(
            controller: _panelController,  // ربط PanelController
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(32),
              topLeft: Radius.circular(32),
            ),
            minHeight: MediaQuery.of(context).size.height * 0.3,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            body: GestureDetector(
              onTap: () => _panelController.close(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            panelBuilder: (ScrollController controller)=>
                _panelBody(controller),
            onPanelSlide: (value){
              if (value >= 0.2){
                if(!_isOpen){
                  setState(() {
                    _isOpen = true;
                  });
                }
              }
            },
            onPanelClosed: (){
              setState(() {
                _isOpen = false;
              });
            },
          )
        ],
      ),
    );
  }

  SingleChildScrollView _panelBody(ScrollController controller) {
    double hPadding = 40;
    return SingleChildScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _titleSection(),
                _infoSection(),
                _actionSection(hPadding: hPadding),
              ],
            ),
          ),
          GridView.builder(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _imageList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (BuildContext context, int index) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_imageList[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _actionSection({double hPadding = 40}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: !_isOpen,
          child: Expanded(
            child: OutlinedButton(
              onPressed: () {
                print('View Profile button pressed');
                _panelController.open();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'VIEW PROFILE',
                style: TextStyle(
                  fontFamily: 'gilory',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_isOpen,
          child: const SizedBox(
            width: 16,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,

            child: SizedBox(
              width: _isOpen ? MediaQuery.of(context).size.width - (2*hPadding) / 1.6:double.infinity,
              child: TextButton(
                onPressed: () => print('Message tapped'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'MESSAGE',
                  style: TextStyle(
                    fontFamily: 'gilory',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Row _infoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Check if the selectedRole is not 'Student'
        if (selectedRole != 'Student') ...[
          _infoCell(title: 'Events Created', value: '3'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey,
          ),
        ],
        _infoCell(title: 'Events Joined', value: '15'),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey,
        ),
        _infoCell(title: 'College', value: 'IT'),
      ],
    );
  }

  Column _infoCell({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Column _titleSection() {
    return Column(
      children: [
        Text(
           "${firstNameController.text} ${lastNameController.text}",
          style: TextStyle(
            fontFamily: 'gilory',
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
         Text(
          "${selectedRole}",
          style: TextStyle(
            fontFamily: 'gilory',
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}