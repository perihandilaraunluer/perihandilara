
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import '../Task.dart';

import '../task_list_tile_widget.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
        ),
        body: Padding(
            padding: EdgeInsets.all(30),
          child: ListView(
            children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(30),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 50),
                            )),
                        Container(
                          padding: EdgeInsets.all(30),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'E-mail',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(30),
                          child: TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),

                        Container(
                            height: 50,
                            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.redAccent,
                              child: Text('Login'),
                              onPressed: () {
                                print(usernameController.text);
                                print(passwordController.text);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ToDoScreen()),
                                );

                              },
    )),

            ],
          )));
  }
}


// ignore: must_be_immutable
class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  List<Task> taskList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("To-Do List "),
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String newTaskName = await showModalBottomSheet(
              context: context,
              builder: (context) {
                return AddTaskScreen();
              });
          setState(() {
            taskList.add(Task(taskName: newTaskName, isDone: false));
          });
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          IconButton(
            icon: Icon(Icons.house),
            iconSize: 50,
            color: Colors.redAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
               },),
              Container(
                padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 30),
                child: Text("Things To Do"),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.all(10),
                  padding:
                  EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 70),
                  height: double.minPositive,
                  width: 500,


                child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return TaskListTile(
                        item: taskList[index],
                        onTaskStatusChange: (bool val) {
                          setState(() {
                            taskList[index].isDone = val;
                          });
                        },
                        onDelete: () {
                          setState(() {
                            taskList.removeAt(index);
                          });
                        },
                      );
                    }),


                ),

              )
            ],

          )
         ),
    );
  }

}


class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  var textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text("Add your task"),
          TextField(
            controller: textController,
          ),
          FlatButton(

              child: Text("add"),
              onPressed: () {
                Navigator.pop(context, textController.text);
              })

        ],
      ),
    );

  }
}


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  final picker = ImagePicker();
  File image;
  double get height => MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();

  }

  void onImageButtonPressed(ImageSource source) async{
    try{
      await getImage(source);
    }catch(e){
      print(e);
    }
  }
  Future getImage(ImageSource source) async{
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      image = File(pickedFile.path);
    });
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
  Widget get buildFloatingActionButtons {
    return Column(
      children: [
        Spacer(),
        buildAppIconButtonNewPhoto,
        SizedBox(height: height * 0.01),

      ],
    );
  }
  FloatingActionButton get buildAppIconButtonNewPhoto {
    return FloatingActionButton.extended(
      label: Text("Take Photo"),
      backgroundColor: Colors.redAccent,
      heroTag: "btn1",
      icon: Icon(Icons.photo_camera),
      onPressed: () => onImageButtonPressed(ImageSource.camera),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Home Page"),
        backgroundColor: Colors.redAccent,

      ),
      floatingActionButton: buildFloatingActionButtons,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_chart),
            iconSize: 50,
            color: Colors.redAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ToDoScreen()),
              );
            },),
          SizedBox(
              width: 200.0,
              height: 10.0
          ),
          if(image != null)
            Padding(padding: EdgeInsets.all(20),
            child: Center(
              child:Image.file(
                image,
                width: 200,
                height: 200,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(

              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

              child: Text(
                'Get location',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _getCurrentLocation();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.caption,
                ),
                if (_currentPosition != null &&
                    _currentAddress != null)
                  Text(_currentAddress,
                      style:
                      Theme.of(context).textTheme.bodyText2),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
