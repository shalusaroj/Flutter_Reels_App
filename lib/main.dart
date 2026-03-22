import 'package:flutter/material.dart';
import 'package:reels_assignment/app.dart';
import 'package:reels_assignment/core/firebase/firebase_bootstrap.dart';
import 'package:reels_assignment/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await di.init();
  runApp(const ReelsAssignmentApp());
}
