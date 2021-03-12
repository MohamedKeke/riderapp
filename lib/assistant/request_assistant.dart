import 'dart:convert';

import 'package:http/http.dart' as http;
class RequestAssistant{
  static  Future<dynamic> getRequest(String url) async {
    //encode request
    http.Response response = await http.get(url);
    //decode
   try{
     if(response.statusCode == 200){
       String jSonData = response.body;
       //decode Data
       var decodeData = jsonDecode(jSonData);
       return decodeData;
     }else{
       return "failed";
     }
   }catch(e){
    return "failed";
   }
  }
}