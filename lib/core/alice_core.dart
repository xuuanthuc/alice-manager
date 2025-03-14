import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice_manager/core/alice_utils.dart';
import 'package:alice_manager/helper/alice_export_helper.dart';
import 'package:alice_manager/helper/operating_system.dart';
import 'package:alice_manager/model/alice_configuration.dart';
import 'package:alice_manager/model/alice_export_result.dart';
import 'package:alice_manager/model/alice_http_call.dart';
import 'package:alice_manager/model/alice_http_error.dart';
import 'package:alice_manager/model/alice_http_response.dart';
import 'package:alice_manager/model/alice_log.dart';
import 'package:alice_manager/ui/common/alice_navigation.dart';
import 'package:flutter/material.dart';

class AliceCore {
  /// Configuration of Alice
  late AliceConfiguration _configuration;

  /// Helper used for notification management

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  /// Creates alice core instance
  AliceCore({required AliceConfiguration configuration}) {
    _configuration = configuration;
  }

  /// Returns current configuration
  AliceConfiguration get configuration => _configuration;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _configuration = _configuration.copyWith(navigatorKey: navigatorKey);
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    _unsubscribeFromCallChanges();
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  Future<void> navigateToCallListScreen() async {
    final BuildContext? context = getContext();
    if (context == null) {
      AliceUtils.log(
        'Cant start Alice HTTP Inspector. Please add NavigatorKey to your '
        'application',
      );
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      await AliceNavigation.navigateToCallsList(core: this);
      _isInspectorOpened = false;
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() =>
      _configuration.navigatorKey?.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  FutureOr<void> addCall(AliceHttpCall call) =>
      _configuration.aliceStorage.addCall(call);

  /// Add error to existing alice http call
  FutureOr<void> addError(AliceHttpError error, int requestId) =>
      _configuration.aliceStorage.addError(error, requestId);

  /// Add response to existing alice http call
  FutureOr<void> addResponse(AliceHttpResponse response, int requestId) =>
      _configuration.aliceStorage.addResponse(response, requestId);

  /// Remove all calls from calls subject
  FutureOr<void> removeCalls() => _configuration.aliceStorage.removeCalls();

  /// Selects call with given [requestId]. It may return null.
  @protected
  AliceHttpCall? selectCall(int requestId) =>
      _configuration.aliceStorage.selectCall(requestId);

  /// Returns stream which returns list of HTTP calls
  Stream<List<AliceHttpCall>> get callsStream =>
      _configuration.aliceStorage.callsStream;

  /// Returns all stored HTTP calls.
  List<AliceHttpCall> getCalls() => _configuration.aliceStorage.getCalls();

  /// Save all calls to file.
  Future<AliceExportResult> saveCallsToFile(BuildContext context) =>
      AliceExportHelper.saveCallsToFile(
        context,
        _configuration.aliceStorage.getCalls(),
      );

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) => _configuration.aliceLogger.add(log);

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) => _configuration.aliceLogger.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;

  /// Unsubscribes storage for call changes.
  void _unsubscribeFromCallChanges() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
  }
}
