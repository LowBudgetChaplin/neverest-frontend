// UI lifecycle states
enum FlowState {
  idle,
  loading,
  success,
  error,
  content,
  empty
}

// Bool conventions for a readable UI logic
extension FlowStateExtension on FlowState {
  bool get isLoading => this == FlowState.loading;
  bool get isError => this == FlowState.error;
  bool get isSuccess => this == FlowState.success;
  bool get isContent => this == FlowState.content;
  bool get isEmpty => this == FlowState.empty;
  bool get isIdle => this == FlowState.idle;
}

// How errors can be shown to the user
enum ErrorDisplayType {
  none,
  dialog,
  dialogUpdateApp,
  snackbar,
}
