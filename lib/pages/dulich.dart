import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/login/sign/login.dart';
import 'package:flutterApp/login/sign/sign.dart';
import 'package:flutterApp/bottom/bottomnav.dart';
import 'package:provider/provider.dart';

class Dulich extends StatefulWidget {
  const Dulich({super.key});

  @override
  State<Dulich> createState() => _DulichState();
}

class _DulichState extends State<Dulich> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Center(
          child: Column(
            children: [
              Text(
                'Location',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    Text(
                      'DA NANG, VN',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Search bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Categories list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    categoryCard('Coffee', Icons.coffee),
                    categoryCard('Sea', Icons.waves),
                    categoryCard('Restaurant', Icons.restaurant),
                    categoryCard('Forest', Icons.park),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Top Trips section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Top Trips list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    tripCard('Bà Nà Hills', 'Đà Nẵng', 'assets/images/ba-na-hills.jpg', 40, 4.5),
                    tripCard('Công Viên Châu Á', 'Đà Nẵng', 'assets/images/cong-vien-chau-a-tai-xuat-sau-4-thang-tam-dung-hoat-dong-02.jpg', 40, 4.5),
                    tripCard('Cầu Rồng', 'Đà Nẵng', 'assets/images/cau-rong-da-nang-1-1.jpg', 40, 4.5),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Group Trips section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Group Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Group Trips card in a row (horizontal scrolling)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    tripCard('Trịnh Cà Phê', 'Seelisburg, Norway', 'assets/images/445000712_18031367006093830_4055709656047111081_n.jpg', 60, 4.8),
                    tripCard('Nam House', 'Đà Nẵng', 'assets/images/ghe-tham-nam-house-coffee-ngoi-nha-co-kinh-giua-long-da-nang-03-1636472374.jpg', 60, 4.8),
                    tripCard('Tan', 'Đà Nẵng', 'assets/images/03pydqwux8ne1698946307047.jpg', 60, 4.8),
                  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Category Card Widget
  Widget categoryCard(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Text(title, style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  // Trip Card Widget
  Widget tripCard(String title, String location, String imagePath, double price, double rating) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, height: 120, width: 180, fit: BoxFit.cover),
          ),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(location, style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text('\$$price/visit', style: TextStyle(color: Colors.green)),
              Spacer(),
              Icon(Icons.star, color: Colors.orange, size: 16),
              Text(rating.toString(), style: TextStyle(fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}
