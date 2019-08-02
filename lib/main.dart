import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'dart:core';
import 'package:math_expressions/math_expressions.dart';

void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {

  SpeechRecognition _speechRecognition;
  bool _isAvailable=false,_isListening=false;
  String resultText="",res="",updateExp="";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
    _checkAudioPermission();
  }

  void _checkAudioPermission() async {
    bool hasPermission=await SimplePermissions.checkPermission(Permission.RecordAudio);
    if(!hasPermission) await SimplePermissions.requestPermission(Permission.RecordAudio);
  }

  void initSpeechRecognizer() {
    _speechRecognition=SpeechRecognition();
    _speechRecognition.setAvailabilityHandler((bool result)=>setState(()=>_isAvailable=result));
    _speechRecognition.setRecognitionStartedHandler(()=>setState(()=>_isListening=true));
    _speechRecognition.setRecognitionResultHandler((String speech)=>setState(()=>resultText=speech),);
    _speechRecognition.setRecognitionCompleteHandler(()=>setState(()=>_isListening=false),);
    _speechRecognition.activate().then((result)=>setState(()=>_isAvailable=result));
  }

  Future<String> evaluateExpressions(String exp) async {
    Parser p=Parser();
    updateArithmetic(exp);
    //print("Update expression = $updateExp");
    //if(updateExp == '40 + 3') print('Oh yeah');
    //else print('Hell no');
    Expression expression=p.parse(updateExp);
    String result=expression.evaluate(EvaluationType.REAL, null).toString();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      setState(() {
                        res="";
                      });
                      _speechRecognition.listen(locale: "en_US").then((result)=>print('$result'));
                    _speechRecognition.listen().catchError((onError) {
                      _isAvailable=true;
                      _isListening=false;
                    });
                  },
                  backgroundColor: Colors.pink,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 14.0)),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.cyanAccent[100],
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 14.0)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: RaisedButton(
                color: Colors.lightGreen,
                child: Text('GET RESULTS',style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  evaluateExpressions(resultText).then((value) {
                    setState(() {
                      res=value;
                      var temp=double.parse(res);
                      temp=num.parse(temp.toStringAsFixed(4));
                      res=temp.toString();
                    });
                  });
                }
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 14.0)),
            Text(
              res,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.red
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateArithmetic(String exp) {
    List<String> coded=["add ","append ","divided by","divide by","into","X","to","with","subtract ","from","x","multiply ","by"];
    List<String> decoded=["","","/","/","*","*","+","+","","-","*","","*"];
    Map<String,String> map=Map.fromIterables(coded,decoded);
    updateExp=map.entries.fold(exp, (prev, e) => prev.replaceAll(e.key,e.value));
  }
}