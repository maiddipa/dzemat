import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../i18n/dzemat_locale_controller.dart';
class DzematContactPeopleSection extends StatefulWidget{const DzematContactPeopleSection({super.key});@override State<DzematContactPeopleSection> createState()=>_ContactsState();}
class _ContactsState extends State<DzematContactPeopleSection>{late final future=load();Future<List<dynamic>> load()async{final r=await http.get(Uri.parse('https://dzematbochum.de/kontakti.json'));final json=jsonDecode(utf8.decode(r.bodyBytes));return json['people'] as List<dynamic>? ?? [];}
 @override Widget build(BuildContext context){final l=DzematLocaleController.instance;return AnimatedBuilder(animation:l,builder:(context,_)=>FutureBuilder<List<dynamic>>(future:future,builder:(context,s){if(s.hasError)return const Text('Kontaktliste nicht verfügbar');if(!s.hasData)return const CircularProgressIndicator();return Column(children:[Text(l.t('contacts')), ...s.data!.whereType<Map>().map((p)=>ListTile(title:Text('${p['name']??''}'),subtitle:Text('${p[l.code=='de'?'roleDe':'roleBs']??''}'))),const ListTile(title:Text('Džemat Bochum'),subtitle:Text('Hochstraße 92, 44866 Bochum\nikc-bb@outlook.de\n0177 7540425'))]);}));}}
