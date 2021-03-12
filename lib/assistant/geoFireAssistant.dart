import 'package:rider_app/Models/nearbyAvailableDrivers.dart';
//step 3
class GeoFireAssistants{
  static List<NearbyAvailableDrivers> nearbyAvailableDriversList = [];
  //remove driver offline
static void removeDriverOfflineList(String key){
  int index = nearbyAvailableDriversList.indexWhere((element) => element.key == key);
  nearbyAvailableDriversList.removeAt(index);
}
static void updateNearByDriverLocation(NearbyAvailableDrivers driver){
  int index = nearbyAvailableDriversList.indexWhere((element) => element.key == driver.key);
  nearbyAvailableDriversList[index].latitude = driver.latitude;
  nearbyAvailableDriversList[index].longitude = driver.longitude;
}
}