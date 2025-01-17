import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thread/appScreens/editProfileScreen.dart';
import 'package:thread/authPages/Login.dart';
import 'package:thread/models/thread_messages_model.dart';
import 'package:thread/widgets/thread_message_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Create three variables
  String userName = "";
  String profileName = "";
  String userBio = "";

// Creating instance of Panel controller
PanelController panelController = PanelController();
  // Is Panel Open boolean this will help us whenever we will click on Edit Profile it will notice that panel is open TRUE or not open False
  bool isPanelOpen = false;
  //Getting Data from Firestore

  final currentUser = FirebaseAuth.instance.currentUser;
  Future<void> getUserProfileData() async {
    try {
      // saving all the incoming data from firestore in userData
      final userData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.uid)
          .get();
      if (mounted) {
        // If mounted collection and doc were found
        setState(() {
          // Calling set State and from userData getting all the required info
          userName = userData['userName'];
          profileName = userData['FullName'];
          userBio = userData['bio'];
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Aus admi ka Threads fetch krny hain jis ka account login ha
// Creating a Stream method which will convert all incoming data into List and return a stream
  // this stream method will return streams which are in list and Type is like ThreadMessageModel
  Stream<List<ThreadMessageModel>> fetchUserThreads() {
    // Return the FirebaseFirestore data as List to do this follow steps
    return FirebaseFirestore.instance
        // First after creating instance we call Collection
        .collection('Threads')
        /* Than Inside the collection where you directly want to go so we mentioned that
        // In that case inside threads collection we have a documents with different Ids (not UID)
        // And user each post has different document ID. 
        // So when we are saving thread we are also saving the UID of user so we said to function
        // That Where 'id' is equal to that currentlogin User UID. So instead of documents it will 
        // Check inside the all documents data so jahan pr b User ki UID match kry gi vo thread user ki
        hogien tu vo fetch kr ly ga */
        .where('id', isEqualTo: currentUser!.uid)
        // . Snapshots will get the data Snapshot of all data
        .snapshots()
        // and Converting that Snapshots to .map((snapshot){})
        .map((snapshot) {
      // Inside Map we return the snapshot.docs.map((doc){})

      return snapshot.docs.map((doc) {
        // Now Data from snapshot is in the doc variable
        // We create a seprate variable called messageData which will fetch and save all doc.data in messageData

        final messageData =
            doc.data(); // messageData type will auto change to map
        /* Now we will also show the Time of thread posting so that's why we will call and convert timestamp to data
        which will give us the exact time of posting
        */
        final timestamp = (messageData['time'] as Timestamp).toDate();
        /* No when we get all data so we are returning the ThreadMessageModel 
        and inside this Model we will pass the complete Data which is required by this model from messageData

      */
        return ThreadMessageModel(
            id: doc.id,
            senderName: messageData['sender'],
            senderProfileImageUrl: "",
            message: messageData['thread'],
            timeStamp: timestamp);
        // Then we convert streams data to List
      }).toList();
    });
  }

  @override
  void initState() {
    getUserProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          // Wrapping the SafeArea with Sliding Up Panel to show the Edit profile screen as a Slider
          body: SlidingUpPanel(
            // Set the panel Controller instance as a controller
            controller: panelController,
            // Setting Min height
            minHeight: 0,
            // 0.9% mean it will take 90% of the Screen
            maxHeight: MediaQuery.of(context).size.height *0.9 ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25)
            ),
            //SlidingPanel also take pageBuilder PageBuilder vo ha jahan pr Jo page ham show krvana chahty in this case we will show EditProfile
            panelBuilder: (ScrollController sc) {
              // So we return the class which we will show Sliding Panel will pop up
              return  EditProfile(panelController:panelController,);
            },
            // And in Body we will return the other created Widgets
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(profileName),
                      subtitle: Text(userName),
                      contentPadding: const EdgeInsets.all(0),
                      trailing: const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                            "https://assets.about.me/background/users/n/k/t/nktechtube_1658465013_975.jpg"),
                      ),
                    ),
                    Text(userBio),
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        "100 Followers",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              // if condition is true
                              if(isPanelOpen){
                                // sliding Panel will close
                                panelController.close();
                              }else{
                                // else if isPanelOpen is false we will Open the panel
                                panelController.open();
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Edit Profile"),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(),));
                            },
                            child: Container(
                              height: 30,
                              width: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Logout"),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const TabBar(
                        labelColor: Colors.black,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(text: "Thread"),
                          Tab(text: "Replies"),
                          Tab(text: "Reposts"),
                        ]),
                    SizedBox(height: 20,),
                    Expanded(
                        child: TabBarView(children: [
                      // Showing User Own Threads which were posted by them Using Stream Builder
                      StreamBuilder(
                          // Set the fetchuserThreads (Stream method) as a stream
                          stream: fetchUserThreads(),
                          builder: (context, snapshot) {
                            // If Snapshot contains any data
                            if (snapshot.hasData) {
                              // Then we create a userThread Variable and it save the snapshot.data in it
                              // So userTHread will automatically change its DataType as per Data
                              // In this case userThread will be a List
                              final userThread = snapshot.data;
                              // Now after getting data we will return the ListView.builder
                              return ListView.builder(
                                //setting the itemCount using the userThread because its a list and it contain all data from stream method
            
                                itemCount: userThread!.length,
                                itemBuilder: (context, index) {
                                  /* create another messageData variable and in this variable we will pass the userThread List and 
                                          pass the listview builder index in it 
                                          */
                                  final messageData = userThread[index];
                                  /* Now we as we know ThreadMessageWidget is getting data from ThreadMessagModel so that''s
                                  why we will pass the data from Stream into ThreadMessageModel and ThreadmessageWidget will
                                  get the data from Model. So model will get the new data whenever we will call it or assign new values
                                   
                                   */
                                  final messageModel = ThreadMessageModel(
                                      id: messageData.id,
                                      senderName: messageData.senderName,
                                      senderProfileImageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS28hpNCB0d4qFEvL4SVbsAGzRmYUg9KOO4PA&s",
                                      message: messageData.message,
                                      timeStamp: messageData.timeStamp);
                                      /* In last we are returning the Widget which is ThreadMessageWidget and all data like profile image
                                     message, posting data as designed in this Widget class
                                     But this Threadmessagewidget also need the variable of ThreadMessageModel
                                     so message Model is the ThreadMessageModel instance so we will pass it to
                                     ThreadMessaegWidget....
                                          */
                                  return ThreadMessageWidget(
                                      messageModel: messageModel);
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            } else {
                              return  Text("loading");
                            }
                          }),
            
                      const Center(child: Text("Your Replies here")),
                      const Center(child: Text("Your Reposts here")),
                    ]))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
