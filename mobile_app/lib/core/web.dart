import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Ouvre l'URL dans un nouvel onglet du navigateur.
bool openUrl(String url) {
  globalContext.callMethodVarArgs<JSAny?>(
    'open'.toJS,
    <JSAny?>[url.toJS, '_blank'.toJS],
  );
  return true;
}