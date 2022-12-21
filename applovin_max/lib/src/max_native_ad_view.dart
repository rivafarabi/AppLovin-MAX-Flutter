import 'dart:ui' as ui;

import 'package:applovin_max/applovin_max.dart';
import 'package:applovin_max/src/max_native_ad_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Represents an ad format.
enum AdTemplate {
  /// The small site native ad template.
  small("small"),
  /// The medium site native ad template.
  medium("medium");

  /// @nodoc
  final String value;

  /// @nodoc
  const AdTemplate(this.value);
}

const double _bannerWidth = 320;
const double _bannerHeight = 50;
const double _leaderWidth = 728;
const double _leaderHeight = 90;
const double _mrecWidth = 300;
const double _mrecHeight = 250;

/// Represents a native ad view.
class MaxNativeAdView extends StatefulWidget {
  /// A string value representing the ad unit ID to load ads for.
  final String adUnitId;

  final AdTemplate adTemplate;

  /// A string value representing the placement name that you assign when you integrate each ad format, for granular reporting in ad events.
  final String? placement;

  /// A string value representing the customData name that you assign when you integrate each ad format, for granular reporting in ad events.
  final String? customData;

  /// The listener for various ad callbacks.
  final AdViewAdListener? listener;

  /// Creates a new native ad directly in the user's widget tree.
  const MaxNativeAdView({
    Key? key,
    required this.adUnitId,
    required this.adTemplate,
    this.placement,
    this.customData,
    this.listener,
  }) : super(key: key);

  /// @nodoc
  @override
  State<MaxNativeAdView> createState() => _MaxNativeAdViewState();
}

class _MaxNativeAdViewState extends State<MaxNativeAdView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return SizedBox(
        width: _getWidth(),
        height: _getHeight(),
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          child: AndroidView(
            viewType: "applovin_max/native",
            creationParams: <String, dynamic>{
              "ad_unit_id": widget.adUnitId,
            },
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onMaxNativeAdViewCreated,
          ),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: _getWidth(),
        height: _getHeight(),
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          child: UiKitView(
            viewType: "applovin_max/native",
            creationParams: <String, dynamic>{
              "ad_unit_id": widget.adUnitId,
            },
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onMaxNativeAdViewCreated,
          ),
        ),
      );
    }

    return Container();
  }

  void _onMaxNativeAdViewCreated(int id) {
    print('applovin_max/native_$id');
    final MethodChannel channel = MethodChannel('applovin_max/native_$id');

    channel.setMethodCallHandler((call) async {
      var method = call.method;
      var arguments = call.arguments;

      var adUnitId = arguments["adUnitId"];

      if ("OnNativeAdLoadedEvent" == method) {
        widget.listener?.onAdLoadedCallback(AppLovinMAX.createAd(adUnitId, arguments));
      } else if ("OnNativeAdLoadFailedEvent" == method) {
        widget.listener?.onAdLoadFailedCallback(adUnitId, AppLovinMAX.createError(arguments));
      } else if ("OnNativeAdClickedEvent" == method) {
        widget.listener?.onAdClickedCallback(AppLovinMAX.createAd(adUnitId, arguments));
      } else if ("OnNativeAdViewAdRevenuePaidEvent" == method) {
        widget.listener?.onAdRevenuePaidCallback?.call(AppLovinMAX.createAd(adUnitId, arguments));
      }
    });
  }

  double _getWidth() {
    // if (widget.adFormat == AdFormat.mrec) {
    //   return _mrecWidth;
    // } else if (widget.adFormat == AdFormat.banner) {
    //   return _isTablet() ? _leaderWidth : _bannerWidth;
    // }

    return _mrecWidth;

    return -1;
  }

  double _getHeight() {
    // if (widget.adFormat == AdFormat.mrec) {
    //   return _mrecHeight;
    // } else if (widget.adFormat == AdFormat.banner) {
    //   return _isTablet() ? _leaderHeight : _bannerHeight;
    // }

    return _mrecHeight;

    return -1;
  }

  bool _isTablet() {
    final double devicePixelRatio = ui.window.devicePixelRatio;
    final ui.Size size = ui.window.physicalSize;
    final double width = size.width;
    final double height = size.height;

    if (devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) {
      return true;
    } else if (devicePixelRatio == 2 && (width >= 1920 || height >= 1920)) {
      return true;
    } else {
      return false;
    }
  }
}
