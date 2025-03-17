import 'package:app/Gane_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  late AnimationController _animationController;
  RewardedAd? _rewardedAd;
  int userPoints = 0; // Points counter

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();

    // Animation for button scaling effect
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner Ad ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad Failed to Load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Interstitial Ad ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad Failed to Load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        if (_interstitialAd != null) {
          _interstitialAd!.show();
          _interstitialAd = null; // Dispose after showing
          _loadInterstitialAd(); // Load next ad
        } else {
          print('Interstitial Ad Not Ready');
          _loadInterstitialAd();
        }
      });
    });
  }

  // Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test Rewarded Ad ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded Ad Failed to Load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  // Show Rewarded Ad and Give Points
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        setState(() {
          userPoints += 10; // Increase points when ad is fully watched
        });
        print('User Earned Reward! Points: $userPoints');
      });
      _rewardedAd = null;
      _loadRewardedAd(); // Load next ad
    } else {
      print('Rewarded Ad Not Ready');
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 29, 7, 57),
              Color.fromARGB(255, 99, 70, 142)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),

            // Show User Points
            Text(
              "Your Points: $userPoints",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),

            // Watch Ad Button with Animation
            Center(
              child: ScaleTransition(
                  scale: _animationController,
                  child: Shimmer.fromColors(
                    baseColor: Color.fromARGB(255, 220, 106, 108),
                    highlightColor: Colors.white,
                    period: Duration(seconds: 2),
                    child: GestureDetector(
                      onTap: _showInterstitialAd,
                      child: Container(
                        height: 57.73,
                        width: 216,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Color.fromARGB(255, 220, 106, 108),),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_outline_outlined, size: 37, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Watch Ad", style: TextStyle(fontSize: 24, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
              ),
            ),
            SizedBox(height: 20),
            // Button to Watch Rewarded Ad and Earn Points
            ScaleTransition(
                scale: _animationController,
                child: Shimmer.fromColors(
                  baseColor: Color.fromARGB(255, 220, 106, 108),
                  highlightColor: Colors.white,
                  period: Duration(seconds: 2),
                  child: GestureDetector(
                    onTap: _showRewardedAd,
                    child: Container(
                      height: 57.73,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Color.fromARGB(255, 220, 106, 108),),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline_outlined, size: 37, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Watch Ad & Earn Points", style: TextStyle(fontSize: 24, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ),

            // SizedBox(height: 20),
            // ElevatedButton(
            //     onPressed: (){
            //       Navigator.push(context, MaterialPageRoute(builder: (_)=>TicTacToeScreen()));
            //     },
            //     child: Text("New Page")
            // ),


            Spacer(),

            // Banner Ad
            if (_isBannerAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
