import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WebView extends StatelessWidget {
  // Define a view id
  final String _viewId = "web-view";

  WebView() {
    // TODO : -

    // Register the view factory with the id
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => html.IFrameElement()
        ..width = "1500"
        ..height = "200"
        ..src = "assets/assets/camera.html" // Set the source to your HTML file
        ..style.border = "none",
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewId,
    );
  }
}
