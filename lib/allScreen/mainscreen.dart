import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/divider.dart';
import 'package:rider_app/AllWidgets/progressDiolog.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/Models/nearbyAvailableDrivers.dart';
import 'package:rider_app/allScreen/search_screen.dart';
import 'package:rider_app/appData/app_data.dart';
import 'package:rider_app/assistant/assistant_methods.dart';
import 'package:rider_app/assistant/geoFireAssistant.dart';
import 'package:rider_app/conigMapsKey/config_maps.dart';

import 'login_screen.dart';
class MainScreen extends StatefulWidget {
  static const idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  DirectionDetails tripDirectionDetails;
  double rideDetailsContainer = 0.0;
  double searchContainerHeight = 300.0;
  double requestRideContainerHeight = 0;
  bool drawerOpen = true;
  bool nearbyAvailableDriversLoaded = false;
  DatabaseReference rideRequestRef;
  BitmapDescriptor nearByIcon;
  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentUserOnline();
  }
  //Current User
  void saveRideRequest(){
    rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context,listen: false).dropOffLocation;

    Map pickLocMap = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };
    Map dropOfLockMap = {
      'latitude': dropOff.latitude.toString(),
      'longitude': dropOff.longitude.toString(),
    };
    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pickup': pickLocMap,
      'dropoff': dropOfLockMap,
      'created_at': DateTime.now().toString(),
      'rider_name': userCurrentInfo.name,
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOff.placeName,
    };
    rideRequestRef.set(rideInfoMap);
  }
  void cancelRequestRide(){
    rideRequestRef.remove();
  }
  void displayRequestRideContainer(){
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainer = 0.0;
      bottomPaddingMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }
  GlobalKey<ScaffoldState> scafoldKey = GlobalKey<ScaffoldState>();
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLinesSet ={};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingMap = 0;
  void resetApp(){
    setState(() {
      searchContainerHeight = 300.0;
      rideDetailsContainer = 0.0;
      requestRideContainerHeight = 0.0;
      bottomPaddingMap = 230.0;
      drawerOpen = true;

      markersSet.clear();
      polyLinesSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }
  void displayDetailsContainer()async{
    await getPlaceDirection();
    searchContainerHeight = 0.0;
    rideDetailsContainer = 240.0;
    bottomPaddingMap = 230.0;
    drawerOpen = false;
  }
  //Function GEOLOCATOR
   locatePosition()async{
   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    _newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String  address = await AssistantMethods.searchCoordinatedAddress(position, context);
    print("your address: "+ address);
   initGeoFireListener();
  }
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController _newGoogleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scafoldKey,
      appBar: AppBar(
        title: Text("Farsamayaqaan"),
      ),
      drawer: Container(
        width: 255.0,
       child: Drawer(
         child: ListView(
           children: [
             //drawer Header
             Container(
             height: 165.0,
               decoration: BoxDecoration(color: Colors.white),
               child: DrawerHeader(
                 child: Row(
                   children: [
                     Image.asset("images/user_icon.png",
                     height: 65.0,
                       width: 65.0,
                     ),
                     SizedBox(width: 16.0,),
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Profile Name:", style: TextStyle(
                           fontSize: 16.0,
                           fontFamily: "Brand-Bold"
                         ),),
                         SizedBox(height: 6.0,),
                         Text("Visit Profile"),
                       ],
                     )
                   ],
                 ),
               ),
             ),
             DividerLine(),
             SizedBox(height: 12.0,),
             //Drawer Body
             ListTile(
               leading: Icon(Icons.history),
               title: Text("History", style:TextStyle(fontSize: 16.0)),
             ),
             ListTile(
               leading: Icon(Icons.person),
               title: Text("Visit Profile", style:TextStyle(fontSize: 16.0)),
             ),
             ListTile(
               leading: Icon(Icons.info),
               title: Text("About", style:TextStyle(fontSize: 16.0)),
             ),
             GestureDetector(
               onTap: (){
                 FirebaseAuth.instance.signOut();
                 Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
               },
               child: ListTile(
                 leading: Icon(Icons.logout),
                 title: Text("Logout", style:TextStyle(fontSize: 16.0)),
               ),
             ),
           ],
         ),
       ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingMap),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polyLinesSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
_controllerGoogleMap.complete(controller);
_newGoogleMapController = controller;
setState(() {
  bottomPaddingMap = 300.0;
});
locatePosition();
            },
          ),
          //hunbarg Button 4 Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: (){
                if(drawerOpen){
                  scafoldKey.currentState.openDrawer();
                }
                else{
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            right:0.0,
            left:0.0,
            bottom:0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height:searchContainerHeight,
                decoration:BoxDecoration(
                  color: Colors.white,
                  borderRadius:BorderRadius.only(topLeft:Radius.circular(18.0), topRight:Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color:Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: .5,
                      offset: Offset(.7, .7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0,),
                      Text(
                        "Hi, There.",
                        style:TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        //'Where to?'
                        "Any Where?",
                        style:TextStyle(
                          fontSize: 20.0,
                          fontFamily: "Brand-Bold",
                        ),
                      ),
                      SizedBox(height:20.0),
                      //second container search
                      GestureDetector(
                        onTap: ()async{
                        var res = await Navigator.of(context).push(MaterialPageRoute(
                             builder: (context)=>SearchScreen()));
                        if(res == "obtainDirection"){
                          displayDetailsContainer();
                        }
                        },
                        child: Container(
                          decoration:BoxDecoration(
                            borderRadius:BorderRadius.circular(6.0),
                            color:Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6.0,
                                spreadRadius: .5,
                                offset: Offset(.7, .7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search,color:Colors.blueAccent),
                                SizedBox(height: 10.0,),
                                Text("Search A Technician Man!!"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0,),
                      Row(
                        children: [
                          Icon(Icons.home, color:Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                             Provider.of<AppData>(context).pickUpLocation != null
                                  ? Provider.of<AppData>(context).pickUpLocation.placeName
                                 : "Add Home"
                              ),
                              SizedBox(width: 4.0,),
                              Text("Your living Address",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0
                              ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      DividerLine(),
                      SizedBox(height: 10.0,),
                      Row(
                        children: [
                          Icon(Icons.work, color:Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(width: 4.0,),
                              Text("Your Office Address",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.0
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
Positioned(
  left: 0.0,
  right: 0.0,
  bottom: 0.0,
  child: AnimatedSize(
    vsync: this,
    curve: Curves.bounceIn,
    duration: new Duration(milliseconds: 160),
    child: Container(
      height: rideDetailsContainer,
      decoration:BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
boxShadow: [BoxShadow(color:Colors.black,spreadRadius: .5,blurRadius: 16.0,offset: Offset(.7, .7),),],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:17.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.tealAccent[100],
              child:Padding(
                padding: EdgeInsets.symmetric(horizontal:16.0),
                child: Row(
                  children: [
                    Image.asset("images/taxi.png", height: 70.0,width:80.0),
                    SizedBox(width: 16.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Car", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),
                        ),
                        Text(
                          (tripDirectionDetails != null)? tripDirectionDetails.distancesText : "NO",style: TextStyle(fontSize: 16.0, color:Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      ((tripDirectionDetails != null) ? '\$ ${AssistantMethods.calculateAmountFares(tripDirectionDetails)}':'NO'),style: TextStyle(fontFamily: "Brand-Bold"),
                    ),
                  ],
                )
              )
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:20.0),
              child: Row(
                children:[
                  Icon(FontAwesomeIcons.moneyCheckAlt, size:18.0,color:Colors.black54),
                  SizedBox(width:16.0),
                  Text("Cash",),
                  SizedBox(width:6.0),
                  Icon(Icons.keyboard_arrow_down, size:16.0,color:Colors.black54),
                ],
              ),
            ),
            SizedBox(height:24.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:16.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Request", style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color:Colors.white,
                      ),
                      ),
                      Icon(FontAwesomeIcons.taxi, size: 26.0,color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: requestRideContainerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft:Radius.circular(16.0), topRight: Radius.circular(16.0),),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: .5,
                    blurRadius: 16.0,
                    offset: Offset(.7, .7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height:12.0),
                    SizedBox(
                    width: double.infinity,
    child: ColorizeAnimatedTextKit(
    onTap: () {
    print("Tap Event");
    },
    text: [
    "Request a Man.",
    "Please Wait.",
    "Finding a Man.",
    ],
    textStyle: TextStyle(
    fontSize: 55.0,
    fontFamily: "Signatra",
    ),
    colors: [
      Colors.green,
    Colors.purple,
      Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
    ],
    textAlign: TextAlign.center,
    ),
    ),
                    SizedBox(height: 22.0,),
                    GestureDetector(
                      onTap: (){
                        cancelRequestRide();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300], width: 2.0),
                          borderRadius: BorderRadius.circular(26.0),
                          color: Colors.white,
                        ),
                        child: Icon(Icons.close, size:26.0),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel",textAlign: TextAlign.center, style: TextStyle(
                        fontSize: 12.0,
                      ),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> getPlaceDirection()async{
    var initialPos = Provider.of<AppData>(context).pickUpLocation;
    var finalPos = Provider.of<AppData>(context).dropOffLocation;

    var pickUpLAtLng = LatLng(initialPos.latitude,initialPos.longitude);
    var dropOffLAtLng = LatLng(finalPos.latitude,finalPos.longitude);
//show dialog
  showDialog(context: context, builder: (BuildContext context)=>ProgressBar(message: "Please wait..."));
  var details = await AssistantMethods.obtainPlaceDirectionsDetails(pickUpLAtLng, dropOffLAtLng);
  //fare Amount
    setState(() {
      tripDirectionDetails = details;
    });
  Navigator.pop(context);
  print("HELLO THIS IS DETAILS ::::");
  print(details.encodedPoints);
  //instance of polyLine
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointResult = polylinePoints.decodePolyline(details.encodedPoints);
    pLineCoordinates.clear();
    //check PolyLines
    if(decodePolyLinePointResult.isNotEmpty){
      decodePolyLinePointResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLinesSet.clear();
    //instance of PolyLine
  setState(() {
    Polyline polyline = Polyline(
      color: Colors.pink,
      width: 5,
      points: pLineCoordinates,
      jointType: JointType.round,
      polylineId: PolylineId("PolyLineId"),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    polyLinesSet.add(polyline);
    //go map screen and add polylines
  });
  LatLngBounds latLngBounds = LatLngBounds();
  if(pickUpLAtLng.latitude > dropOffLAtLng.latitude && pickUpLAtLng.longitude > dropOffLAtLng.longitude){
    latLngBounds = LatLngBounds(southwest: dropOffLAtLng, northeast: pickUpLAtLng);
  }
  else  if(pickUpLAtLng.longitude > dropOffLAtLng.longitude){
    latLngBounds = LatLngBounds(southwest:LatLng(pickUpLAtLng.latitude, dropOffLAtLng.longitude), northeast: LatLng(dropOffLAtLng.latitude,pickUpLAtLng.longitude));
  }
  else  if(pickUpLAtLng.latitude > dropOffLAtLng.latitude){
    latLngBounds = LatLngBounds(southwest:LatLng(dropOffLAtLng.latitude, pickUpLAtLng.longitude), northeast: LatLng(pickUpLAtLng.latitude,dropOffLAtLng.longitude));
  }
  else{
    latLngBounds = LatLngBounds(southwest: pickUpLAtLng, northeast: dropOffLAtLng);
  }
  _newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
//pickUp Marker
  Marker pickUpLocMarker = Marker(
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
    position: pickUpLAtLng,
    markerId: MarkerId("PickUpId"),
  );
  //Drop Off Marker
  //   Marker dropOffLocMarker = Marker(
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //     infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Drop Off Location"),
  //     position: dropOffLAtLng,
  //     markerId: MarkerId("dropOffId"),
  //   );
    setState(() {
      markersSet.add(pickUpLocMarker);
     // markersSet.add(dropOffLocMarker);
    });
    Circle pickUpLocCircle = Circle(
      strokeWidth: 4,
        radius: 12,
        strokeColor: Colors.amber,
        center: pickUpLAtLng,
        fillColor: Colors.blueGrey,
        circleId: CircleId("PickUpId"),
    );
    // Circle dropOffLocCircle = Circle(
    //   strokeWidth: 4,
    //   radius: 12,
    //   strokeColor: Colors.deepOrangeAccent,
    //   center: dropOffLAtLng,
    //   fillColor: Colors.brown,
    //   circleId: CircleId("dropOffId"),
    // );
    setState(() {
     circlesSet.add(pickUpLocCircle);
     //circlesSet.add(dropOffLocCircle);
    });
  }
  //step one
  void initGeoFireListener(){
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 10).listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
nearbyAvailableDrivers.key = map['key'];
nearbyAvailableDrivers.latitude = map['latitude'];
nearbyAvailableDrivers.longitude = map['latitude'];
GeoFireAssistants.nearbyAvailableDriversList.add(nearbyAvailableDrivers);
if(nearbyAvailableDriversLoaded == true){
  updateAvailableDriversOnMap();
}
            break;

          case Geofire.onKeyExited:
GeoFireAssistants.removeDriverOfflineList(map['key']);
updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
          // Update your key's location
            NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['latitude'];
            GeoFireAssistants.updateNearByDriverLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
          // All Intial Data is loaded
            updateAvailableDriversOnMap();

            break;
        }
      }
      setState(() {});
    });
  }
  //step 4
  void updateAvailableDriversOnMap(){
    setState(() {
    markersSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for(NearbyAvailableDrivers drivers in GeoFireAssistants.nearbyAvailableDriversList){
      LatLng driverAvailablePosition = LatLng(drivers.latitude, drivers.longitude);
      Marker marker = Marker(
        markerId: MarkerId("MarkerId ${drivers.key}"),
        position: driverAvailablePosition,
        icon: nearByIcon,
        rotation: AssistantMethods.craeteRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }
  void createIconMarker(){
    if(nearByIcon == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2,2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios")
          .then((value){
         nearByIcon = value;
      });
    }
  }
}
