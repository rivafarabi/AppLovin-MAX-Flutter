package com.applovin.applovin_max;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.applovin.mediation.MaxAd;
import com.applovin.mediation.MaxAdRevenueListener;
import com.applovin.mediation.MaxError;
import com.applovin.mediation.ads.MaxAdView;
import com.applovin.mediation.nativeAds.MaxNativeAd;
import com.applovin.mediation.nativeAds.MaxNativeAdListener;
import com.applovin.mediation.nativeAds.MaxNativeAdLoader;
import com.applovin.mediation.nativeAds.MaxNativeAdView;
import com.applovin.mediation.nativeAds.MaxNativeAdViewBinder;
import com.applovin.sdk.AppLovinSdk;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class AppLovinMAXNativeAdView extends MaxNativeAdListener
        implements PlatformView, MaxAdRevenueListener
{
    private MethodChannel       channel;
    private MaxNativeAdLoader   nativeAdLoader;
    private MaxNativeAdView     adView;
    private MaxAd               loadedNativeAd ;
    private FrameLayout         nativeAdContainer;
    private MaxNativeAdViewBinder binder;

    public AppLovinMAXNativeAdView(final int viewId, final String adUnitId, @Nullable final String placement, @Nullable final String customData, final BinaryMessenger messenger, final AppLovinSdk sdk, final Context context)
    {
        String uniqueChannelName = "applovin_max/native_" + viewId;
        channel = new MethodChannel( messenger, uniqueChannelName );

         binder = new MaxNativeAdViewBinder.Builder(R.layout.native_custom_ad_layout)
                .setTitleTextViewId(R.id.title_text_view)
                .setBodyTextViewId(R.id.body_text_view)
                .setMediaContentViewGroupId(R.id.media_view_container)
                .setAdvertiserTextViewId(R.id.advertiser_textView)
                .setOptionsContentViewGroupId(R.id.ad_options_view)
                .setCallToActionButtonId(R.id.cta_button)
                .build();

        adView = new MaxNativeAdView(binder, context);

        nativeAdContainer = new FrameLayout(context);

        nativeAdLoader = new MaxNativeAdLoader(adUnitId, sdk, context);

        nativeAdLoader.setNativeAdListener( this );
        nativeAdLoader.setRevenueListener( this );

        nativeAdLoader.loadAd(adView);
    }

    @Nullable
    @Override
    public View getView()
    {
        return adView;
    }

    @Override
    public void onFlutterViewAttached(@NonNull final View flutterView) { }

    @Override
    public void onFlutterViewDetached() { }

    @Override
    public void dispose()
    {
        if ( nativeAdLoader != null )
        {
            nativeAdLoader.destroy();
            nativeAdLoader.setNativeAdListener(null);
            nativeAdLoader.setRevenueListener( null );
        }
    }

    @Override
    public void onAdRevenuePaid(final MaxAd ad)
    {
        sendEvent( "OnNativeAdViewAdRevenuePaidEvent", ad );
    }

    @Override
    public void onNativeAdLoaded(final MaxNativeAdView nativeAdView, final MaxAd ad)
    {
        // Clean up any pre-existing native ad to prevent memory leaks.
        if ( loadedNativeAd  != null )
        {
            nativeAdLoader.destroy(loadedNativeAd);
        }

        // Save ad for cleanup.
        loadedNativeAd = ad;

        sendEvent("OnNativeAdLoadedEvent", ad);

        MaxNativeAd nativeAd = ad.getNativeAd();

        // Add ad view to view.
        nativeAdContainer.removeAllViews();
        nativeAdContainer.addView(nativeAdView);
    }

    @Override
    public void onNativeAdLoadFailed(final String adUnitId, final MaxError error) {
        AppLovinMAX.getInstance().fireErrorCallback("OnNativeAdLoadFailedEvent", adUnitId, error);
    }

    @Override
    public void onNativeAdClicked(final MaxAd ad) {
        sendEvent("OnNativeAdClickedEvent", ad);
    }

    private void sendEvent(final String event, final MaxAd ad)
    {
        AppLovinMAX.getInstance().fireCallback( event, ad, channel );
    }
}
