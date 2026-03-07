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

  static const String BASE =
      'https://raw.githubusercontent.com/mosmanbabar/menuverse-models/main/';

  final List<Map<String, dynamic>> menuItems = [
    {
      'emoji': '🍔',
      'label': 'Burger',
      'modelUrl': '${BASE}burger.glb',
      'data': '''{
        "id": "smash-burger",
        "name": "Smash Burger",
        "description": "Juicy smash burger with special sauce",
        "price": "Rs. 850", "originalPrice": "Rs. 1000",
        "rating": 4.8, "reviews": 120,
        "prepTime": "15 min", "calories": "650 cal",
        "tags": ["Bestseller", "Spicy"],
        "ingredients": ["Beef Patty", "Cheese", "Lettuce", "Special Sauce"],
        "modelUrl": "${BASE}burger.glb",
        "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd"
      }'''
    },
    {
      'emoji': '🍕',
      'label': 'Pizza',
      'modelUrl': '${BASE}pizza.glb',
      'data': '''{
        "id": "margherita-pizza",
        "name": "Margherita Pizza",
        "description": "Stone baked with fresh mozzarella",
        "price": "Rs. 1200", "originalPrice": null,
        "rating": 4.6, "reviews": 189,
        "prepTime": "18 min", "calories": "650 cal",
        "tags": ["Vegetarian", "Classic"],
        "ingredients": ["Pizza Dough", "Mozzarella", "Basil", "Tomato Sauce"],
        "modelUrl": "${BASE}pizza.glb",
        "imageUrl": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002"
      }'''
    },
    {
      'emoji': '🌮',
      'label': 'Taco',
      'modelUrl': '${BASE}taco.glb',
      'data': '''{
        "id": "taco-platter",
        "name": "3-Piece Taco Platter",
        "description": "Crispy tacos with guacamole and salsa",
        "price": "Rs. 650", "originalPrice": "Rs. 800",
        "rating": 4.5, "reviews": 156,
        "prepTime": "10 min", "calories": "480 cal",
        "tags": ["Deal", "Customizable"],
        "ingredients": ["Taco Shell", "Chicken", "Guacamole", "Salsa"],
        "modelUrl": "${BASE}taco.glb",
        "imageUrl": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47"
      }'''
    },
  ];

  String _currentModelUrl = '${BASE}burger.glb';

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (url.contains('menuverse-core.html')) {
            _loadItem(menuItems[0]['data']!, menuItems[0]['modelUrl']!);
          }
        },
        onWebResourceError: (error) {
          print('❌ Error: ${error.description}');
        },
        onNavigationRequest: (request) async {
          // Intercept AR intent — handle Flutter se
          if (request.url.startsWith('intent://')) {
            await _launchAR(_currentModelUrl);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadFlutterAsset('assets/menuverse-core.html');
  }

  void _loadItem(String itemJson, String modelUrl) {
    setState(() => _currentModelUrl = modelUrl);
    controller.runJavaScript('mvLoadItem($itemJson)');
  }

  // AR — Scene Viewer direct launch
  Future<void> _launchAR(String modelUrl) async {
    final encodedModel = Uri.encodeComponent(modelUrl);
    // Scene Viewer ka proper URL format
    final sceneViewerUrl = 'https://arvr.google.com/scene-viewer/1.0'
        '?file=$encodedModel'
        '&mode=ar_preferred'
        '&title=MenuVerse+3D';

    final uri = Uri.parse(sceneViewerUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MenuVerse Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuItems.map((item) {
                return GestureDetector(
                  onTap: () => _loadItem(item['data']!, item['modelUrl']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: Text(
                      '${item['emoji']} ${item['label']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}