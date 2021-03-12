
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Models/addresses.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/appData/app_data.dart';
import 'dart:convert';

import 'package:rider_app/assistant/request_assistant.dart';
import 'package:rider_app/conigMapsKey/config_maps.dart';

class AssistantMethods{
  static Future<String> searchCoordinatedAddress(Position position, context)async{
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(url);
    // ignore: unrelated_type_equality_checks
    if(response != "failed"){
      //placeAddress = response["results"][0]["formatted_address"];
     // placeAddress = response["results"][0]["formatted_address"][0];
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + " " + st2 + " " + st3 + " " + st4 ;
      Address userPickUpAddress =new Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }
  static Future<DirectionDetails> obtainPlaceDirectionsDetails(LatLng initialPosition, LatLng finalPosition)async{
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=YOUR_API_KEY";
    var res = await RequestAssistant.getRequest(directionUrl);
    if(res == "failed"){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distancesText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distancesValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValues = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }
  static int calculateAmountFares(DirectionDetails directionDetails){
    double timeTravelledFare = (directionDetails.durationValues / 60) * 0.20;
    double distanceTravelledFare = (directionDetails.durationValues / 1000) * 0.20;
    double totalAmountFare = timeTravelledFare + distanceTravelledFare;
    // local currency
    // 1$ = 8500sh
    // timeTravelledFare * 8500;
    return totalAmountFare.truncate();
  }
  //Current User Online
static void getCurrentUserOnline(){
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapshot){
if(dataSnapshot.value != null){
  userCurrentInfo = Users.fromSnapshot(dataSnapshot);
}
    } );
}

//step5
static double craeteRandomNumber(int num){
    var random = Random();
    int ranNumber = random.nextInt(num);
    return ranNumber.toDouble();
}
}



