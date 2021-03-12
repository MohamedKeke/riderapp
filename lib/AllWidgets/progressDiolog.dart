import 'package:flutter/material.dart';

class ProgressBar  extends StatelessWidget {
  final dynamic message;
  ProgressBar({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.yellow,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                width: 6.0,
              ),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
              SizedBox(
                width: 25.0,
              ),
              Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
