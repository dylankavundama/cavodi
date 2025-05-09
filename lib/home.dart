import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cavodi/AddEntryDialog.dart';
import 'package:cavodi/FullscreenImagePage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelDiaryPage extends StatefulWidget {
  const TravelDiaryPage({super.key});

  @override
  State<TravelDiaryPage> createState() => _TravelDiaryPageState();
}

class _TravelDiaryPageState extends State<TravelDiaryPage> {
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _startNewGame();
  }

  void _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    entries.removeAt(index);
    await prefs.setString('travel_entries', jsonEncode(entries));
    setState(() {});
  }

  void _shareEntry(Map<String, dynamic> entry) async {
    final title = entry['title'] ?? '';
    final desc = entry['description'] ?? '';
    final date = entry['date'] ?? '';
    final content = '📍 $title\n🗓️ $date\n📝 $desc';

    final List<String> imagePaths = List<String>.from(entry['photos'] ?? []);
    List<File> imageFiles = [];

    // Convertir les chemins d'image en objets File
    for (String path in imagePaths) {
      imageFiles.add(File(path));
    }

    if (imageFiles.isNotEmpty) {
      // Partager avec les images
      Share.shareFiles(
        imageFiles.map((file) => file.path).toList(),
        text: content,
      );
    } else {
      // Si aucune image, partager seulement le texte
      Share.share(content);
    }
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('travel_entries');
    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      setState(() {
        entries = decoded
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList()
          ..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      });
    }
  }

  Future<void> _saveEntry(Map<String, dynamic> newEntry) async {
    final prefs = await SharedPreferences.getInstance();
    entries.add(newEntry);
    await prefs.setString('travel_entries', jsonEncode(entries));
    setState(() {});
  }

  void _openAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEntryDialog(onSave: _saveEntry);
      },
    );
  }

//pub

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  //intertial

  InterstitialAd? _interstitialAd;
  final _gameLength = 5;
  late var _counter = _gameLength;
//cavodi
  final String _adUnitIdd = Platform.isAndroid
      ? 'ca-app-pub-8882238368661853/9036053194'
      : 'ca-app-pub-8882238368661853/9036053194';
  void _startNewGame() {
    setState(() => _counter = _gameLength);

    _loadAdd();
    _starTimer();
  }

  void _loadAdd() {
    InterstitialAd.load(
      adUnitId: _adUnitIdd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {},
              onAdImpression: (ad) {},
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
              },
              onAdClicked: (ad) {});

          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  void _starTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _counter--);

      if (_counter == 0) {
        _interstitialAd?.show();
        timer.cancel();
      }
    });
  }

  void go() {
    setState(() {
      _interstitialAd?.show();
    });
  }

  Future<void> allVideo() async {
    setState(() {});
  }

//cavodi actu

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8882238368661853/4044640450'
      : 'ca-app-pub-8882238368661853/4044640450';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _isLoaded = false;
    _loadAd();
  }

  void _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      return;
    }

    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final List imagePaths = entry['photos'] ?? [];
    final title = entry['title'];
    final desc = entry['description'];
    final dateStr = entry['date'];
    final date = dateStr.isNotEmpty ? DateTime.parse(dateStr) : null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePaths.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                  ),
                  items: imagePaths.map<Widget>((path) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FullscreenImagePage(imagePath: path),
                          ),
                        );
                      },
                      child: Image.file(
                        File(path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  if (date != null)
                    Text('${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(color: Colors.grey)),
                  const Divider(),
                  Text(desc),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          final index = entries.indexOf(entry);
                          if (index != -1) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Voulez-vous vraiment supprimer cette entrée ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _deleteEntry(index);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Color(0xFF80B4FB),
                        ),
                        onPressed: () => _shareEntry(entry),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF80B4FB),
          title: const Text('Cavodi')),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Aucun souvenir pour le moment.\nAjoutez votre première aventure !',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              children: entries.reversed.map(_buildEntryCard).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF80B4FB),
        onPressed: _openAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
