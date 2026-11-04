import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class DzematLegalLinks extends StatelessWidget{const DzematLegalLinks({super.key});Future<void> open(String name)async{await launchUrl(Uri.parse('https://dzematbochum.de/$name'),mode:LaunchMode.externalApplication);}@override Widget build(BuildContext context)=>Wrap(children:[TextButton(onPressed:()=>open('datenschutz.html'),child:const Text('Datenschutz')),TextButton(onPressed:()=>open('impressum.html'),child:const Text('Impressum'))]);}
