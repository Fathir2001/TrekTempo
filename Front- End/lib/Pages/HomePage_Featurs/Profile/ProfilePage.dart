import 'package:flutter/material.dart';
import 'package:travel_app/Pages/HomePage_Featurs/MainHomePage.dart';
import 'package:travel_app/Pages/HomePage_Featurs/Profile/EditProfilePage.dart'; // Import the EditProfilePage
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_app/Models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  Future<User>? futureProfile;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
    print('Loading userId from SharedPreferences:::::: ${userId ?? "null"}');

    if (userId != null) {
      futureProfile = fetchProfileData(userId ?? "6700ae680edbeca3aef3e1e5");
    } else {
      print('No userId found in SharedPreferences');
    }
  }

  Future<User> fetchProfileData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/auth/getProfile/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['user'] != null) {
          print('Successfully fetched user profile');

          return User.fromJson(jsonData['user']);
        } else {
          throw Exception('Failed to load user profile');
        }
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MainHomePage(), // Navigate to MainHomePage
              ),
            );
          },
        ),
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage(), // Navigate to EditProfilePage
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // Use FutureBuilder to handle dynamic user data including profile picture
            FutureBuilder<User>(
              future: futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while data is being fetched
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Show error message if something went wrong
                  return Text('Errorrrr: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Display user data once available
                  User user = snapshot.data!;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (user.profilePicURL != null &&
                                user.profilePicURL!.isNotEmpty)
                            ? NetworkImage(user.profilePicURL!)
                            : NetworkImage(
                                'https://sricarschennai.in/wp-content/uploads/2022/11/avatar.png'), // Default image URL
                      ),
                      SizedBox(height: 10),
                      Text(
                        user.name, // User's name
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        user.email, // User's email
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  );
                } else {
                  // Fallback text if no data is available
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/naami.jpg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Naam Ahmed',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }
              },
            ),

            SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(height: 5),
                    Text('23 likes'),
                  ],
                ),
                SizedBox(width: 40),
                Column(
                  children: [
                    Icon(Icons.bookmark, color: Colors.grey),
                    SizedBox(height: 5),
                    Text('5 Saved'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // GridView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: 3,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 3,
            //     childAspectRatio: 1,
            //   ),
            //   itemBuilder: (context, index) {
            //     return Column(
            //       children: [
            //         Image.asset(
            //           'assets/images/MainHome/Sigiriya.png',
            //           fit: BoxFit.cover,
            //         ),
            //         Text('Sigiriya'),
            //       ],
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
