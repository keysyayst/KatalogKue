import 'package:flutter/material.dart';

void main() => runApp(const KueLebaranApp());

class KueLebaranApp extends StatelessWidget {
  const KueLebaranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Kue Lebaran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 18, 18, 18)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritePage(),
    const ContactPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFE8C00),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Contact'),
        ],
      ),
    );
  }
}

/// =====================
/// DATA PRODUK
/// =====================
class Product {
  final String id;
  final String title;
  final String location;
  final int price;
  final String image;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.image,
    this.isFavorite = false,
  });
}

final List<Product> allProducts = [
  Product(id: 'n1', title: 'Nastar Classic', location: 'Malang', price: 70000, image: 'assets/images/nastar.png'),
  Product(id: 'k1', title: 'Kastengel', location: 'Malang', price: 65000, image: 'assets/images/kastengel.png'),
  Product(id: 'l1', title: 'Lidah Kucing', location: 'Malang', price: 50000, image: 'assets/images/lidahkucing.png'),
  Product(id: 's1', title: 'Sagu Keju', location: 'Malang', price: 45000, image: 'assets/images/sagukeju.png'),
  Product(id: 'p1', title: 'Putri Salju', location: 'Malang', price: 55000, image: 'assets/images/putrisalju.png'),
  Product(id: 'c1', title: 'Brownies Cup', location: 'Malang', price: 60000, image: 'assets/images/browniescup.png'),
  Product(id: 'p2', title: 'Palm Cheese', location: 'Malang', price: 50000, image: 'assets/images/palmcheese.png'),
  Product(id: 'b1', title: 'Thumbrint', location: 'Malang', price: 48000, image: 'assets/images/thumbrin.png'),
];

/// =====================
/// HOME PAGE
/// =====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rekomendasi = allProducts.take(4).toList();

    return SafeArea(
      child: Column(
        children: [
          // --- Hero Section ---
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.45), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                bottom: 24,
                child: Text(
                  'Temukan kue terbaik\nuntuk momen spesialmu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Rekomendasi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProdukKamiPage()),
                    );
                  },
                  child: const Text('See All',
                      style: TextStyle(color: Color(0xFFFE8C00))),
                )
              ],
            ),
          ),

          // --- Grid Produk ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: rekomendasi.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: rekomendasi[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// PRODUK KAMI PAGE
/// =====================
class ProdukKamiPage extends StatelessWidget {
  const ProdukKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Kami'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: allProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: allProducts[index]);
          },
        ),
      ),
    );
  }
}

/// =====================
/// PRODUCT CARD
/// =====================
class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
        ).then((_) => setState(() {}));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(p.image, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => p.isFavorite = !p.isFavorite),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        radius: 14,
                        child: Icon(
                          p.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: p.isFavorite ? const Color(0xFFFE8C00) : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFFFE8C00)),
                      const SizedBox(width: 4),
                      Text(p.location, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Rp. ${p.price}',
                      style: const TextStyle(
                          color: Color(0xFFFE8C00), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// DETAIL PRODUK
/// =====================
class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Image.asset(p.image, height: 250, width: double.infinity, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Rp. ${p.price}',
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFFFE8C00))),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.delivery_dining, size: 18),
                        SizedBox(width: 6),
                        Text('Free Delivery'),
                        SizedBox(width: 16),
                        Icon(Icons.timer, size: 18),
                        SizedBox(width: 6),
                        Text('20 - 30 min'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Description',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      'Kue kering khas lebaran dengan cita rasa gurih, renyah, dan manis yang seimbang. Dibuat dengan bahan pilihan terbaik tanpa pengawet.',
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => setState(() => p.isFavorite = !p.isFavorite),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE8C00),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: Icon(p.isFavorite ? Icons.favorite : Icons.favorite_border),
            label: const Text('Tambahkan ke Favorit'),
          ),
        ),
      ),
    );
  }
}

/// =====================
/// FAVORITE PAGE
/// =====================
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final favs = allProducts.where((p) => p.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: favs.isEmpty
          ? const Center(child: Text('Belum ada produk favorit.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: favs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: favs[index]);
                },
              ),
            ),
    );
  }
}

/// =====================
/// CONTACT PAGE
/// =====================
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          const SizedBox(height: 12),
          const Text('Kue Kering Made by Mommy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFFFE8C00)),
            title: const Text('082216849581'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFFFE8C00)),
            title: const Text('kukerbymommy@gmail.com'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
