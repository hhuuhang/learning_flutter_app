import 'package:flutter/material.dart';
import 'package:homework/theme/colors.dart';
import 'package:homework/data/mock.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primary,
        unselectedItemColor: const Color(0xFF4E586E),
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/Home.png"),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/Stream.png"),
            ),
            label: 'Streams',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/message.png"),
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/Notification.png"),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/Profile.png"),
            ),
            label: 'Profiles',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: const Color(0xFFF54B64),
        onTap: null,
      ),
    );
  }

  Widget getBody() {
    return SafeArea(
      child: Container(
        color: primary,
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Icon(
                  Icons.arrow_back,
                  color: white,
                  size: 28,
                ),
                Icon(
                  Icons.add,
                  color: white,
                  size: 38,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Messages",
              style: TextStyle(
                  color: white,
                  fontFamily: 'Avenir',
                  fontSize: 41,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Row(
                      children: List.generate(users.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 75,
                            height: 75,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(users[index]['img']),
                                          fit: BoxFit.cover)),
                                ),
                                Positioned(
                                  top: 48,
                                  left: 52,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: online,
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: white, width: 3)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 80,
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  users[index]['name'],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: white,
                                  ),
                                )),
                          )
                        ],
                      ),
                    );
                  }))
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 0,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: List.generate(userMessages.length, (index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 75,
                                height: 75,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  userMessages[index]['img']),
                                              fit: BoxFit.cover)),
                                    ),
                                    (userMessages[index]['num_mess']
                                            .toString()
                                            .isNotEmpty)
                                        ? Positioned(
                                            top: 48,
                                            left: 42,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: num_mess,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: white, width: 3),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  userMessages[index]
                                                      ['num_mess'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width) -
                                        135,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width) -
                                              215,
                                          child: Text(
                                            userMessages[index]['name'],
                                            style: const TextStyle(
                                              color: white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            userMessages[index]['created_at'],
                                            style: const TextStyle(
                                                color: time_mess),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 135,
                                    child: Text(
                                      userMessages[index]['message'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: white,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0,
                        thickness: 2,
                        indent: 95,
                        endIndent: 0,
                        color: Colors.black,
                      ),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
