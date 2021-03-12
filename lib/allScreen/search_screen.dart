
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/progressDiolog.dart';
import 'package:rider_app/Models/addresses.dart';
import 'package:rider_app/Models/place_prediction.dart';
import 'package:rider_app/appData/app_data.dart';
import 'package:rider_app/assistant/request_assistant.dart';
import 'package:rider_app/conigMapsKey/config_maps.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress;
    //String placeAddress = Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    // ignore: unnecessary_statements
    placeAddress != null ? Provider.of<AppData>(context).pickUpLocation.placeName : "nooooo";
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      backgroundColor: Colors.white.withAlpha(480),
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration:   BoxDecoration(
                color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius:.5,
                    blurRadius: 6.0,
                    offset:Offset(.7,.7 )
                )
              ]
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5,),
                  Stack(
                    children: [
                      GestureDetector(
                          child: Icon(Icons.arrow_back_ios),
                      onTap: (){
                            Navigator.of(context).pop();
                      },
                      ),
                      Center(
                        //"Set Drop Off"
                        child: Text("Search your city", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),),
                      )
                    ],
                  ),
                  SizedBox(height: 24.0,),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset("images/pickicon.png", height:16.0 , width: 16.0,),
                        SizedBox(height: 18,),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                //  hintText: "PickUp Location",
                                    hintText: "Your Location Address",
                                  fillColor: Colors.grey,
                                  border: InputBorder.none,
                                  filled: true,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left:11.0, top: 8.0, bottom: 8.0)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Row(
                    children: [
                      Image.asset("images/desticon.png", height:16.0 , width: 16.0,),
                      SizedBox(height: 18,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val){
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                 // hintText: "Where to ? ",
                                  hintText: "Which city?",
                                  fillColor: Colors.grey,
                                  border: InputBorder.none,
                                  filled: true,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left:11.0, top: 8.0, bottom: 8.0)
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 15.0,),
          //Prediction Tile
          (placePredictionList.length > 0) ?
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListView.separated(
                  padding: EdgeInsets.all(0.0),
                  itemBuilder: (context, index){
                    return PredictionTile(placePrediction: placePredictionList[index],);},
                  separatorBuilder: (context, index)=>Divider(height: 5.0,),
                  itemCount: placePredictionList.length,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                ),
              )
              : Container()
        ],
      ),
    );
  }
  void findPlace(String placeName)async{
   if(placeName.length > 1){
     String autoCompleteUrl ="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:so";
  var res = await RequestAssistant.getRequest(autoCompleteUrl);
  if(res == "failed"){
    return;
  }

     if("status" == "OK"){
       var predictions = res["predictions"];
       var placeList = (predictions as List).map((e) => PlacePredictions.fromJSon(e)).toList();
       setState(() {
         placePredictionList = placeList;
       });
     }else{
       print("WELCOME GOOGLE PLACES RESPONSES ::" );
       print(res);
     }
   }
  }
}
class PredictionTile  extends StatelessWidget {
  final PlacePredictions placePrediction;
  PredictionTile({Key key, this.placePrediction}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceAddressDetails(placePrediction.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(height: 14.0,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0,),
                      Text(
                        placePrediction.main_text,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0, ),
                      ),
                      SizedBox(height: 2.0,),
                      Text(
                        placePrediction.secondary_text,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color:Colors.grey),
                      ),
                      SizedBox(height: 8.0,),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void getPlaceAddressDetails(String placeId, context)async{
    showDialog(
        context: null,
    builder: (BuildContext context)=> ProgressBar(message: "Setting Drop off, please wait...",)
    );
    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    //return dialog
    Navigator.of(context).pop();
    if(res == "failed"){
      return;
    }
    if(res["status"] == "OK"){
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.latitude = res["result"]["geometry"]["location"]["lng"];
Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);
print("DROP OFF LOCATION ::::");
print(address.placeName);
      print("ERROR OCCURED ::::");
      Navigator.pop(context, "obtainDirection");
    }
  }
}
//Update using provider

