
import 'package:flutter/material.dart';
import 'package:rider_app/Models/addresses.dart';

class AppData extends ChangeNotifier{
  Address pickUpLocation, dropOffLocation;
  void updatePickUpLocationAddress(Address pickUpAddress){
pickUpLocation = pickUpAddress;
notifyListeners();
  }
  void updateDropOffLocationAddress(Address dropOffLocation){
    dropOffLocation = dropOffLocation;
    notifyListeners();
  }
}
