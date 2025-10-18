import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/router/routes_manager.dart';
import '../../l10n/app_localizations.dart';
import '../errors/server_error.dart';
import '../utils/constants.dart';
import 'flow_mode.dart';

/// Common UI state model for screens and viewmodels
abstract class BaseState {
  final FlowState flowState;
  final String? errorMessage;
  final int? errorCode;
  final ErrorDisplayType errorDisplayType;

  const BaseState({
    this.flowState = FlowState.idle,
    this.errorMessage,
    this.errorCode,
    this.errorDisplayType = ErrorDisplayType.none
  });
}

/// Riverpod StateNotifier base that centralizes state transitions and error handling
abstract class BaseViewModel<T extends BaseState> extends StateNotifier<T> {
  BaseViewModel(super.state);

  T copyWithState({
    FlowState? flowState,
    String? errorMessage,
    int? errorCode,
    ErrorDisplayType? errorDisplayType,
    bool forceErrorMessage,
    bool forceErrorCode
  });

  // Sets the screen to the loading state while an operation is being processed in the background
  void setLoading() {
    state = copyWithState(flowState: FlowState.loading);
  }

  // Sets the screen to the normal content state
  void setContent() {
    state = copyWithState(flowState: FlowState.content);
  }

  // Sets the screen to the success state after an operation completes
  void setSuccess() {
    state = copyWithState(flowState: FlowState.success);
  }

  // Maps a server Failure to a localized message and side effects
  // It is called only if the messages coming from the server are not translated into the set language and it is called in view instead of setError()
  void handleError(Failure failure, AppLocalizations l10n, BuildContext context) {
    String resolvedMessage;

    switch(failure.code) {
      case Constants.CONNECTION_ERROR:
        resolvedMessage = l10n.no_internet_connection;
        break;
      case Constants.UNAUTHORIZED_CODE:
        resolvedMessage = "";
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.loginRoute,
                (route) => false,
            arguments: { Constants.ARG_LOGIN_SCREEN_ERROR: resolvedMessage });
        break;
      case Constants.UNPROCESSABLE_ENTITY_CODE:
        resolvedMessage = l10n.increase_version;
        break;
      case Constants.INTERNAL_SERVER_ERROR_CODE:
        resolvedMessage = l10n.internal_server_error;
        break;
      default:
      resolvedMessage = l10n.unknown_error;
    }
  }

  // Clears error info and returns to content; forces errorMessage/errorCode to null
  void resetFlowState() {
    state = copyWithState(
        flowState: FlowState.content,
        errorMessage: null,
        errorCode: null,
        forceErrorMessage: true,
        forceErrorCode: true
    );
  }

  // Moves to error state with a code, message, and how to display it
  void setError(int? errorCode, String message, {ErrorDisplayType type = ErrorDisplayType.snackbar}) {
    state = copyWithState(
        flowState: FlowState.error,
        errorCode: errorCode,
        errorMessage: message,
        errorDisplayType: type
    );
  }

  // Sets the screen to the empty state (no data to show)
  void setEmpty() {
    state = copyWithState(flowState: FlowState.empty);
  }

  // Returns to the idle (initial/inactive) state
  void setIdle() {
    state = copyWithState(flowState: FlowState.idle);
  }
}