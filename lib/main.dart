import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuVerseTestPage(),
    );
  }
}

class MenuVerseTestPage extends StatefulWidget {
  const MenuVerseTestPage({super.key});

  @override
  State<MenuVerseTestPage> createState() => _MenuVerseTestPageState();
}

class _MenuVerseTestPageState extends State<MenuVerseTestPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (url.contains('menuverse-core.html')) {
            print('✅ Page loaded: $url');
            loadTestItem();
          }
        },
        onWebResourceError: (error) {
          print('❌ WebView Error: ${error.description}');
        },
        onNavigationRequest: (request) async {
          // AR intent URL — Flutter se handle karo
          if (request.url.startsWith('intent://')) {
            try {
              final uri = Uri.parse(request.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                // ARCore nahi hai — Play Store pe bhejo
                final playStore = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.google.ar.core'
                );
                await launchUrl(playStore, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              print('AR Error: $e');
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadFlutterAsset('assets/menuverse-core.html');
  }

  void loadTestItem() {
    const item = '''
    {
      "id": "smash-burger",
      "name": "Smash Burger",
      "description": "Juicy smash burger with special sauce",
      "price": "Rs. 850",
      "originalPrice": "Rs. 1000",
      "rating": 4.8,
      "reviews": 120,
      "prepTime": "15 min",
      "calories": "650 cal",
      "tags": ["Bestseller", "Spicy"],
      "ingredients": ["Beef Patty", "Cheese", "Lettuce", "Special Sauce"],
      "modelUrl": "https://raw.githubusercontent.com/mosmanbabar/menuverse-models/main/burger.glb",
      "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd"
    }
    ''';
    controller.runJavaScript('mvLoadItem($item)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MenuVerse Test')),
      body: WebViewWidget(controller: controller),
      floatingActionButton: FloatingActionButton(
        onPressed: loadTestItem,
        child: const Icon(Icons.restaurant_menu),
      ),
    );
  }
}