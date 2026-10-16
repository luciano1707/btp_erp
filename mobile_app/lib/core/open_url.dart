import 'stub.dart' if (dart.library.js_interop) 'web.dart' as impl;

/// Ouvre [url] dans un nouvel onglet (web) ou retourne false si la plateforme ne le permet pas.
bool openUrl(String url) => impl.openUrl(url);