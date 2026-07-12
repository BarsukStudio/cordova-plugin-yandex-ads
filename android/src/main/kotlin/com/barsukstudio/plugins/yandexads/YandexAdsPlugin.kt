package com.barsukstudio.plugins.yandexads

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.yandex.mobile.ads.common.AdError
import com.yandex.mobile.ads.common.AdRequest
import com.yandex.mobile.ads.common.AdRequestError
import com.yandex.mobile.ads.common.ImpressionData
import com.yandex.mobile.ads.common.YandexAds
import com.yandex.mobile.ads.interstitial.InterstitialAd
import com.yandex.mobile.ads.interstitial.InterstitialAdEventListener
import com.yandex.mobile.ads.interstitial.InterstitialAdLoadListener
import com.yandex.mobile.ads.interstitial.InterstitialAdLoader
import com.yandex.mobile.ads.rewarded.Reward
import com.yandex.mobile.ads.rewarded.RewardedAd
import com.yandex.mobile.ads.rewarded.RewardedAdEventListener
import com.yandex.mobile.ads.rewarded.RewardedAdLoadListener
import com.yandex.mobile.ads.rewarded.RewardedAdLoader

@CapacitorPlugin(name = "YandexAds")
class YandexAdsPlugin : Plugin() {
    private var initialized = false
    private var initializingCall: PluginCall? = null

    private var interstitialAdLoader: InterstitialAdLoader? = null
    private var interstitialAd: InterstitialAd? = null
    private var interstitialAdUnitId = ""
    private var interstitialLoadCall: PluginCall? = null

    private var rewardedAdLoader: RewardedAdLoader? = null
    private var rewardedAd: RewardedAd? = null
    private var rewardedAdUnitId = ""
    private var rewardedLoadCall: PluginCall? = null

    @PluginMethod
    fun initialize(call: PluginCall) = runOnMainThread {
        call.getBoolean("userConsent")?.let(YandexAds::setUserConsent)
        call.getBoolean("ageRestricted")?.let(YandexAds::setAgeRestricted)
        call.getBoolean("locationTracking")?.let(YandexAds::setLocationTracking)
        call.getBoolean("enableLogging")?.let(YandexAds::enableLogging)

        if (initialized) {
            call.resolve(versionResult())
            return@runOnMainThread
        }
        if (initializingCall != null) {
            call.reject("Yandex Ads initialization is already in progress", "INITIALIZATION_IN_PROGRESS")
            return@runOnMainThread
        }

        initializingCall = call
        YandexAds.initialize(context) {
            initialized = true
            initializingCall?.resolve(versionResult())
            initializingCall = null
        }
    }

    @PluginMethod
    fun setUserConsent(call: PluginCall) = setBoolean(call, YandexAds::setUserConsent)

    @PluginMethod
    fun setAgeRestricted(call: PluginCall) = setBoolean(call, YandexAds::setAgeRestricted)

    @PluginMethod
    fun setLocationTracking(call: PluginCall) = setBoolean(call, YandexAds::setLocationTracking)

    @PluginMethod
    fun prepareInterstitial(call: PluginCall) = runOnMainThread {
        val adUnitId = requireAdUnitId(call) ?: return@runOnMainThread
        if (!requireInitialized(call)) return@runOnMainThread
        if (interstitialLoadCall != null) {
            call.reject("An interstitial load is already in progress", "LOAD_IN_PROGRESS")
            return@runOnMainThread
        }

        destroyInterstitialAd()
        interstitialAdUnitId = adUnitId
        interstitialLoadCall = call
        if (interstitialAdLoader == null) interstitialAdLoader = InterstitialAdLoader(context)
        val request = AdRequest.Builder(adUnitId).build()
        interstitialAdLoader?.loadAd(request, object : InterstitialAdLoadListener {
            override fun onAdLoaded(interstitialAd: InterstitialAd) {
                this@YandexAdsPlugin.interstitialAd = interstitialAd
                notifyListeners("interstitialLoaded", adEvent(interstitialAdUnitId))
                interstitialLoadCall?.resolve()
                interstitialLoadCall = null
            }

            override fun onAdFailedToLoad(error: AdRequestError) {
                val event = errorEvent(interstitialAdUnitId, error.code, error.description)
                notifyListeners("interstitialFailedToLoad", event)
                interstitialLoadCall?.reject(error.description, "INTERSTITIAL_LOAD_FAILED")
                interstitialLoadCall = null
            }
        })
    }

    @PluginMethod
    fun isInterstitialReady(call: PluginCall) = runOnMainThread {
        call.resolve(JSObject().put("ready", interstitialAd != null))
    }

    @PluginMethod
    fun showInterstitial(call: PluginCall) = runOnMainThread {
        val ad = interstitialAd
        val currentActivity = activity
        if (ad == null) {
            call.reject("Interstitial ad is not ready", "AD_NOT_READY")
            return@runOnMainThread
        }
        if (currentActivity == null) {
            call.reject("Android Activity is unavailable", "ACTIVITY_UNAVAILABLE")
            return@runOnMainThread
        }

        ad.setAdEventListener(object : InterstitialAdEventListener {
            override fun onAdShown() = notifyListeners("interstitialShown", adEvent(interstitialAdUnitId))
            override fun onAdClicked() = notifyListeners("interstitialClicked", adEvent(interstitialAdUnitId))
            override fun onAdImpression(impressionData: ImpressionData?) = notifyListeners("interstitialImpression", adEvent(interstitialAdUnitId))
            override fun onAdDismissed() {
                notifyListeners("interstitialDismissed", adEvent(interstitialAdUnitId))
                destroyInterstitialAd()
            }

            override fun onAdFailedToShow(adError: AdError) {
                notifyListeners("interstitialFailedToShow", errorEvent(interstitialAdUnitId, null, adError.description))
                destroyInterstitialAd()
            }
        })
        ad.show(currentActivity)
        call.resolve()
    }

    @PluginMethod
    fun prepareRewarded(call: PluginCall) = runOnMainThread {
        val adUnitId = requireAdUnitId(call) ?: return@runOnMainThread
        if (!requireInitialized(call)) return@runOnMainThread
        if (rewardedLoadCall != null) {
            call.reject("A rewarded ad load is already in progress", "LOAD_IN_PROGRESS")
            return@runOnMainThread
        }

        destroyRewardedAd()
        rewardedAdUnitId = adUnitId
        rewardedLoadCall = call
        if (rewardedAdLoader == null) rewardedAdLoader = RewardedAdLoader(context)
        val request = AdRequest.Builder(adUnitId).build()
        rewardedAdLoader?.loadAd(request, object : RewardedAdLoadListener {
            override fun onAdLoaded(rewarded: RewardedAd) {
                rewardedAd = rewarded
                notifyListeners("rewardedLoaded", adEvent(rewardedAdUnitId))
                rewardedLoadCall?.resolve()
                rewardedLoadCall = null
            }

            override fun onAdFailedToLoad(error: AdRequestError) {
                val event = errorEvent(rewardedAdUnitId, error.code, error.description)
                notifyListeners("rewardedFailedToLoad", event)
                rewardedLoadCall?.reject(error.description, "REWARDED_LOAD_FAILED")
                rewardedLoadCall = null
            }
        })
    }

    @PluginMethod
    fun isRewardedReady(call: PluginCall) = runOnMainThread {
        call.resolve(JSObject().put("ready", rewardedAd != null))
    }

    @PluginMethod
    fun showRewarded(call: PluginCall) = runOnMainThread {
        val ad = rewardedAd
        val currentActivity = activity
        if (ad == null) {
            call.reject("Rewarded ad is not ready", "AD_NOT_READY")
            return@runOnMainThread
        }
        if (currentActivity == null) {
            call.reject("Android Activity is unavailable", "ACTIVITY_UNAVAILABLE")
            return@runOnMainThread
        }

        ad.setAdEventListener(object : RewardedAdEventListener {
            override fun onAdShown() = notifyListeners("rewardedShown", adEvent(rewardedAdUnitId))
            override fun onAdClicked() = notifyListeners("rewardedClicked", adEvent(rewardedAdUnitId))
            override fun onAdImpression(impressionData: ImpressionData?) = notifyListeners("rewardedImpression", adEvent(rewardedAdUnitId))
            override fun onRewarded(reward: Reward) {
                notifyListeners("rewarded", JSObject().apply {
                    put("adUnitId", rewardedAdUnitId)
                    put("amount", reward.amount)
                    put("type", reward.type)
                })
            }

            override fun onAdDismissed() {
                notifyListeners("rewardedDismissed", adEvent(rewardedAdUnitId))
                destroyRewardedAd()
            }

            override fun onAdFailedToShow(adError: AdError) {
                notifyListeners("rewardedFailedToShow", errorEvent(rewardedAdUnitId, null, adError.description))
                destroyRewardedAd()
            }
        })
        ad.show(currentActivity)
        call.resolve()
    }

    override fun handleOnDestroy() {
        runOnMainThread {
            interstitialLoadCall?.reject("Plugin was destroyed", "PLUGIN_DESTROYED")
            rewardedLoadCall?.reject("Plugin was destroyed", "PLUGIN_DESTROYED")
            initializingCall?.reject("Plugin was destroyed", "PLUGIN_DESTROYED")
            interstitialLoadCall = null
            rewardedLoadCall = null
            initializingCall = null
            interstitialAdLoader?.cancelLoading()
            rewardedAdLoader?.cancelLoading()
            interstitialAdLoader = null
            rewardedAdLoader = null
            destroyInterstitialAd()
            destroyRewardedAd()
        }
    }

    private fun setBoolean(call: PluginCall, setter: (Boolean) -> Unit) = runOnMainThread {
        val value = call.getBoolean("value")
        if (value == null) {
            call.reject("value is required", "INVALID_ARGUMENT")
            return@runOnMainThread
        }
        setter(value)
        call.resolve()
    }

    private fun requireInitialized(call: PluginCall): Boolean {
        if (!initialized) call.reject("Call initialize() before loading ads", "NOT_INITIALIZED")
        return initialized
    }

    private fun requireAdUnitId(call: PluginCall): String? {
        val value = call.getString("adUnitId")?.trim()
        if (value.isNullOrEmpty()) call.reject("adUnitId is required", "INVALID_ARGUMENT")
        return value?.takeIf(String::isNotEmpty)
    }

    private fun versionResult() = JSObject().put("version", YandexAds.libraryVersion)
    private fun adEvent(adUnitId: String) = JSObject().put("adUnitId", adUnitId)
    private fun errorEvent(adUnitId: String, code: Int?, message: String) = JSObject().apply {
        put("adUnitId", adUnitId)
        code?.let { put("code", it) }
        put("message", message)
    }

    private fun destroyInterstitialAd() {
        interstitialAd?.setAdEventListener(null)
        interstitialAd = null
    }

    private fun destroyRewardedAd() {
        rewardedAd?.setAdEventListener(null)
        rewardedAd = null
    }

    private fun runOnMainThread(block: () -> Unit) {
        activity?.runOnUiThread(block) ?: bridge.executeOnMainThread(block)
    }
}
