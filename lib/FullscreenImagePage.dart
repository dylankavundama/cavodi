import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FullscreenImagePage extends StatefulWidget {
  final String imagePath;

  const FullscreenImagePage({super.key, required this.imagePath});

  @override
  State<FullscreenImagePage> createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<FullscreenImagePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8882238368661853/3662933868' // Test Android
          : 'ca-app-pub-8882238368661853/3662933868', // Test iOS
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Erreur de chargement pub : $error');
          if (!mounted) return;
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Hero(
                    tag: widget.imagePath,
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            if (_isAdLoaded && _bannerAd != null)
              Container(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
