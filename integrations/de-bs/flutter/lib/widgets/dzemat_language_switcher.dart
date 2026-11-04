import 'package:flutter/material.dart';
import '../i18n/dzemat_locale_controller.dart';
class DzematLanguageSwitcher extends StatelessWidget{const DzematLanguageSwitcher({super.key});@override Widget build(BuildContext context){final l=DzematLocaleController.instance;return AnimatedBuilder(animation:l,builder:(context,_)=>Row(mainAxisSize:MainAxisSize.min,children:[TextButton(onPressed:()=>l.setLanguage('de'),child:const Text('🇩🇪 DE')),TextButton(onPressed:()=>l.setLanguage('bs'),child:const Text('🇧🇦 BS'))]));}}
