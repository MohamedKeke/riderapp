import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rider_app/AllWidgets/progressDiolog.dart';
import 'package:rider_app/allScreen/registration_screen.dart';

import '../main.dart';
import 'mainscreen.dart';

class LoginScreen  extends StatefulWidget {
  static const idScreen = "login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(
           children: [
             SizedBox(height: 35.0,),
             //logo
             Image(
               image: AssetImage("images/logo.png"),
               width: 390.0,
               height: 250.0,
             ),
             SizedBox(height: 1.0,),
             Text(
               "Login as Worker",
               style: TextStyle(
                 fontSize:24.0,
                 fontFamily: "Brand-Bold",
               ),
               textAlign: TextAlign.center,
             ),
             SizedBox(height: 1.0,),
             Padding(
               padding: EdgeInsets.all(20.0),
               child: Column(
                 children: [
                   SizedBox(height: 10.0,),
                   TextField(
                     controller: emailTextEditingController,
                     keyboardType: TextInputType.emailAddress,
                     decoration: InputDecoration(
                       labelText: "Email",
                       labelStyle: TextStyle(
                         fontSize: 14.0,
                       ),
                       hintStyle: TextStyle(
                         fontSize: 10.0,
                         color: Colors.grey,
                       ),
                     ),
                     style: TextStyle(
                       fontSize: 14.0,
                     ),
                   ),
                   SizedBox(height: 1.0,),
                   TextField(
                     controller: passwordTextEditingController,
                     obscureText: true,
                     decoration: InputDecoration(
                       labelText: "Password",
                       labelStyle: TextStyle(
                         fontSize: 14.0,
                       ),
                       hintStyle: TextStyle(
                         fontSize: 10.0,
                         color: Colors.grey,
                       ),
                     ),
                     style: TextStyle(
                       fontSize: 14.0,
                     ),
                   ),
                   SizedBox(height: 20.0,),
                   RaisedButton(
                     color: Colors.yellow,
                     child: Container(
                       height: 50.0,
                       child: Center(
                         child: Text("Login",
                         style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold",color: Colors.white),
                         ),
                       ),
                     ),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(24.0),
                     ),
                     onPressed: (){
                       if(!emailTextEditingController.text.contains("@")) {
                         displayErrorMessage(context, "Email is not Valid.");
                       }else if(passwordTextEditingController.text.isEmpty){
                         displayErrorMessage(context, "Password must be at least 6 characters");
                       }else {
                         loginAndAuthenticateUser(context);
                       }
                     },
                   ),
                   SizedBox(height: 10.0,),
                   FlatButton(
                     child: Text("Don't Have an Account? Register",
                     style: TextStyle(
                       fontFamily: "Brand Bold",
                       fontSize: 18.0
                     ),
                     ),
                     onPressed: (){
                       Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
                     },
                   ),
                 ],
               ),
             ),
           ],
         ),
       ),
     ),
    );
  }
  //instance variable allow us to acces Firebase
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //function
  void loginAndAuthenticateUser(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressBar(message: "Authenticate please wait....",);
      }
    );
    final User firebaseUser = (  await
    _firebaseAuth.signInWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
    ).catchError((error){
      Navigator.pop(context);
      displayErrorMessage(context, "Errors:" + error.toString());
    })).user;
    //check if user created or not
    if(firebaseUser != null){
      //user created save info to firebase
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
        if(snap.value != null){
             //navigate Mainscreen
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayErrorMessage(context, "You are logged In successfully");
        }else{
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayErrorMessage(context, "No record User Exist please create new one!");
        }
      });
    }else{
      Navigator.pop(context);
      //if it is not created display error messages
      displayErrorMessage(context, "Error Occured please can not be signed-in");
    }
  }
}
