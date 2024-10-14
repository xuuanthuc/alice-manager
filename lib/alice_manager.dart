import 'package:alice_manager/alice.dart';
import 'package:alice_manager/model/alice_configuration.dart';
import 'package:alice_manager/overlay_alice.dart';
import 'package:flutter/material.dart';

class AliceManager {
  static final instance = AliceManager();
  final OverlayAlice _overlayAlice = OverlayAlice();
  OverlayAlice get overlayAlice => _overlayAlice;
  final Alice alice = Alice(configuration: AliceConfiguration());

  void init(GlobalKey<NavigatorState> navigationKey) {
    alice.setNavigatorKey(navigationKey);
  }

  void showInspector() => alice.showInspector();

  void addEntryPoint(BuildContext context) =>
      _overlayAlice.insertOverlay(context);
}
