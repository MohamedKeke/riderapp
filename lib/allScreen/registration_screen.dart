
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllWidgets/progressDiolog.dart';

import '../main.dart';
import 'login_screen.dart';
import 'mainscreen.dart';

class RegistrationScreen  extends StatefulWidget {
  static const idScreen = "register";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //define textEditingControllers
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
              SizedBox(height: 20.0,),
              //logo
              Image(
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
              ),
              SizedBox(height: 1.0,),
              Text(
                  "Register as Worker",
                style: TextStyle(
                  fontSize:24.0,
                  fontFamily: "Brand Bold",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.0,),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 1.0,),
                    //name
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                    //email
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
                    //phone
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                    //password
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
                    SizedBox(height: 1.0,),
                    //confirm password
                    // TextField(
                    //   obscureText: true,
                    //   decoration: InputDecoration(
                    //     labelText: "Confirm Password",
                    //     labelStyle: TextStyle(
                    //       fontSize: 14.0,
                    //     ),
                    //     hintStyle: TextStyle(
                    //       fontSize: 10.0,
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    //   style: TextStyle(
                    //     fontSize: 14.0,
                    //   ),
                    // ),
                    SizedBox(height: 10.0,),
                    RaisedButton(
                      color: Colors.yellow,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text("Create Account",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",color: Colors.white),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      onPressed: (){
                        if(nameTextEditingController.text.length <  4){
                        displayErrorMessage(context, "Name must at least 3 Characters.");
                        }else if(!emailTextEditingController.text.contains("@")) {
                          displayErrorMessage(context, "Email is not Valid.");
                        }else if(phoneTextEditingController.text.isEmpty){
                          displayErrorMessage(context, "Phone is a necessary");
                        }else if(passwordTextEditingController.text.length < 7){
                          displayErrorMessage(context, "Password must be at least 6 characters");
                        }else {
                          //save user info to firebase
                          registerNewUser(context);
                        }
                      },
                    ),
                    SizedBox(height: 8.0,),
                    FlatButton(
                      onPressed: (){
                        Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                      },
                      child: Text("Have an Account? Login Here",
                        style: TextStyle(
                            fontFamily: "Brand-Bold",
                            fontSize: 18.0,
                        ),
                      ),
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
  //register User in Firebase
void registerNewUser(BuildContext context) async{
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressBar(message: "Authenticate please wait....",);
      }
  );
    // create FirebaseUser with email and Password
 final User firebaseUser = (  await
  _firebaseAuth.createUserWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
  ).catchError((error){
    Navigator.pop(context);
    displayErrorMessage(context, "Errors:" + error.toString());
  })).user;
 //check if user created or not
  if(firebaseUser != null){
    //user created save info to firebase
    Map userDataMap = {
      "name": nameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": phoneTextEditingController.text.trim(),
    };
userRef.child(firebaseUser.uid).set(userDataMap);
displayErrorMessage(context, "Successfully Created an Account");
//navigate Mainscreen
    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  }else{
    Navigator.pop(context);
    //if it is not created display error messages
displayErrorMessage(context, "New User has not been Created");
  }
}
}
displayErrorMessage(BuildContext context, String msg){
  Fluttertoast.showToast(msg: msg);
}