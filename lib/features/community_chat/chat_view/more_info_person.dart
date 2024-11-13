import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreInfoPerson extends StatefulWidget {
  final String recipientName;
  final String recipientImage;
  final String recipientPhone;

  const MoreInfoPerson({
    super.key,
    required this.recipientName,
    required this.recipientImage,
    required this.recipientPhone,
  });

  @override
  State<MoreInfoPerson> createState() => _MoreInfoPersonState();
}

class _MoreInfoPersonState extends State<MoreInfoPerson> {

  bool _isChatLocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.recipientName,
          style: GoogleFonts.chakraPetch(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: const Color(0xffa0cf1a),



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
                    child: Text('Share'),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('View in address book'),
                  ),

                  const PopupMenuItem(
                    value: 3,
                    child: Text('Verify security code'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                // Show dialog with the image when tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent, // Make the background transparent
                      child: AlertDialog(
                        backgroundColor: Colors.transparent, // Also make the dialog background transparent
                        contentPadding: EdgeInsets.zero, // Remove padding for a cleaner look
                        content: SizedBox(
                          child: Image(
                            image: widget.recipientImage.isNotEmpty
                                ? NetworkImage(widget.recipientImage)
                                : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                            fit: BoxFit.contain, // Fit image nicely within the dialog
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: widget.recipientImage.isNotEmpty
                    ? NetworkImage(widget.recipientImage)
                    : const AssetImage('assets/images/placeholder.png') as ImageProvider,
              ),
            ),

            const SizedBox(height: 10),
            Text(
              widget.recipientName,
              style: GoogleFonts.chakraPetch(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 5),
            Text(
              widget.recipientPhone,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),



            Container(
              // color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                    InkWell(
                    onTap: (){},
                  child: Container(
                    width: 75,
                    height:70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        const Icon(Icons.call_outlined, size: 30, color: Colors.green),
                        const SizedBox(height: 5),
                        Text(
                          "Audio",
                          style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.bold
                          )
                        )
                      ],
                    ),
                  ),),

                    InkWell(
                    onTap:(){},
                  child : Container(
                    width: 75,
                    height:70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child:  Column(
                      children: [
                        const SizedBox(height: 5),
                        const Icon(
                           Icons.videocam_outlined, size: 30, color: Colors.green,
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Video",
                          style: GoogleFonts.chakraPetch(
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),),

                    InkWell(
                   onTap:(){},
                   child : Container(
                    width: 75,
                    height:70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child:  Column(
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.currency_rupee_outlined, size: 25, color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Pay",
                          style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),),

                    InkWell(
    onTap:(){},
    child :   Container(
                    width: 75,
                    height:70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child:  Column(
                      children: [
                        const SizedBox(height: 5),
                        const Icon(
                            Icons.search_outlined, size: 28, color: Colors.green,
                          ),

                        const SizedBox(height: 5),

                        Text(
                          "Search",
                          style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),),

                ],
              ),
            ),

            const SizedBox(height: 4),

            Container(
              width:double.infinity,
              height:80,
              decoration: BoxDecoration(
                color:  Colors.white,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: Colors.black.withOpacity(0.15),
                  width: 0.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 0),
                    blurRadius: 1.5,
                    spreadRadius:1,
                  ),
                ],
              ),
             child:Padding(
               padding: const EdgeInsets.only(left:10.0),
              child:Column(
                mainAxisAlignment:MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
               children:[
                  Text(
                " We are the Click Me!! user 😎. \ Here We can Chat 🐣",
                style: GoogleFonts.acme(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

                 Text(
                   "September 2, 2024 ",
                   style: GoogleFonts.acme(
                     fontWeight: FontWeight.bold,
                     fontSize: 12,
                   ),
                 ),
               ]
              ),
             ),
            ),


            const SizedBox(height: 10),

            const Padding(
             padding: EdgeInsets.all(10.0),
            child:Row(
              children: [
                Text('Media, links, and docs'),

                Spacer(),

                Icon(
                    Icons.arrow_forward_ios,
                    size:15,
                ),
              ]
            ),),







            //
            // ListTile(
            //   leading: const Icon(Icons.photo_library),
            //   title: const Text('Media, links, and docs'),
            //   subtitle: const Text('735 items'),
            //   trailing: const Icon(Icons.arrow_forward_ios),
            //   onTap: () {
            //     // Navigate to media screen
            //   },
            // ),




            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to notifications settings
              },
            ),

            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Media visibility'),
              onTap: () {
                // Navigate to media visibility settings
              },
            ),

            ListTile(
              leading: const Icon(Icons.star_outline_outlined),
              title: const Text('Starred messages'),

              trailing: const Text("1"),
              onTap: () {
                // Navigate to notifications settings
              },
            ),




                const ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Encryption'),
                  subtitle: Text('Messages and calls are end-to-end encrypted. Tap to verify.'),
                ),
                const ListTile(
                  leading: Icon(Icons.hourglass_empty),
                  title: Text('Disappearing messages'),
                  subtitle: Text('Off'),
                ),
            ListTile(
              leading:  Icon(CupertinoIcons.lock_circle),
              title: const Text('Chat lock'),
              subtitle: const Text('Lock and hide this chat on this device.'),
              trailing: Switch(
                value: _isChatLocked,
                activeColor: const Color(0xffa0cf1a),
                onChanged: (value) {
                  setState(() {
                    _isChatLocked = value;
                  });
                },
              ),
            ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: Text('Create group with ${widget.recipientName}'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('Add to Favorites'),
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: Text('Block ${widget.recipientName}', style: const TextStyle(color: Colors.red)),
                ),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: Text('Report ${widget.recipientName}', style: const TextStyle(color: Colors.red)),
                ),
          ],
        ),
      ),
    );
  }
}
