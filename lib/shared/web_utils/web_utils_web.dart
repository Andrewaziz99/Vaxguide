import 'dart:js_interop';

@JS('_removeLoadingScreen')
external void _removeLoadingScreen();

/// Calls the JavaScript `_removeLoadingScreen()` function defined in index.html.
void removeWebLoadingScreen() {
  try {
    _removeLoadingScreen();
  } catch (_) {
    // Ignore if the function doesn't exist
  }
}
