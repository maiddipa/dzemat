import 'package:flutter/material.dart';
import '../i18n/dzemat_locale_controller.dart';
import '../widgets/dzemat_contact_people_section.dart';
import '../widgets/dzemat_legal_links.dart';

class AboutPage extends StatelessWidget {
 const AboutPage({super.key});
 @override Widget build(BuildContext context){
 final lang=DzematLocaleController.instance;
 return AnimatedBuilder(animation:lang,builder:(context,_)=>Scaffold(
   appBar:AppBar(title:Text(lang.t('about'))),
   body:ListView(padding:const EdgeInsets.all(20),children:[
     const Text('Džemat Bochum',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
     const SizedBox(height:20),const DzematContactPeopleSection(),
     const SizedBox(height:20),const DzematLegalLinks()
   ])
 ));
 }
}
