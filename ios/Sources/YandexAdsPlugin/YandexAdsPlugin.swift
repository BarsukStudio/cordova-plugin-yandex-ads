import Capacitor
import Foundation
import YandexMobileAds

@objc(YandexAdsPlugin)
public class YandexAdsPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "YandexAdsPlugin"
    public let jsName = "YandexAds"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initialize", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setUserConsent", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setAgeRestricted", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setLocationTracking", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "prepareInterstitial", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isInterstitialReady", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showInterstitial", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "prepareRewarded", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isRewardedReady", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showRewarded", returnType: CAPPluginReturnPromise)
    ]

    private let interstitialAdLoader = InterstitialAdLoader()
    private let rewardedAdLoader = RewardedAdLoader()
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var interstitialAdUnitID = ""
    private var rewardedAdUnitID = ""
    private var initialized = false
    private var initializing = false
    private var interstitialLoading = false
    private var rewardedLoading = false

    @objc func initialize(_ call: CAPPluginCall) {
        runOnMain { self.initializeOnMain(call) }
    }

    @MainActor private func initializeOnMain(_ call: CAPPluginCall) {
        call.getBool("userConsent").map(YandexAds.setUserConsent)
        call.getBool("ageRestricted").map(YandexAds.setAgeRestricted)
        call.getBool("locationTracking").map(YandexAds.setLocationTracking)
        if call.getBool("enableLogging") == true {
            YandexAds.enableLogging()
        }

        if initialized {
            call.resolve(["version": YandexAds.sdkVersion.stringValue])
            return
        }
        guard !initializing else {
            call.reject("Yandex Ads initialization is already in progress", "INITIALIZATION_IN_PROGRESS")
            return
        }

        initializing = true
        YandexAds.initializeSDK { [weak self] in
            guard let self else { return }
            self.initializing = false
            self.initialized = true
            call.resolve(["version": YandexAds.sdkVersion.stringValue])
        }
    }

    @objc func setUserConsent(_ call: CAPPluginCall) {
        runOnMain { self.setBoolean(call, setter: YandexAds.setUserConsent) }
    }

    @objc func setAgeRestricted(_ call: CAPPluginCall) {
        runOnMain { self.setBoolean(call, setter: YandexAds.setAgeRestricted) }
    }

    @objc func setLocationTracking(_ call: CAPPluginCall) {
        runOnMain { self.setBoolean(call, setter: YandexAds.setLocationTracking) }
    }

    @objc func prepareInterstitial(_ call: CAPPluginCall) {
        runOnMain { self.prepareInterstitialOnMain(call) }
    }

    @MainActor private func prepareInterstitialOnMain(_ call: CAPPluginCall) {
        guard requireInitialized(call), let adUnitID = requireAdUnitID(call) else { return }
        guard !interstitialLoading else {
            call.reject("An interstitial load is already in progress", "LOAD_IN_PROGRESS")
            return
        }

        destroyInterstitialAd()
        interstitialAdUnitID = adUnitID
        interstitialLoading = true
        interstitialAdLoader.loadAd(with: AdRequest(adUnitID: adUnitID)) { [weak self] result in
            guard let self else { return }
            self.interstitialLoading = false
            switch result {
            case .success(let ad):
                self.interstitialAd = ad
                ad.delegate = self
                self.notifyListeners("interstitialLoaded", data: self.adEvent(adUnitID))
                call.resolve()
            case .failure(let error):
                self.notifyListeners("interstitialFailedToLoad", data: self.errorEvent(adUnitID, error))
                self.reject(call, error: error, code: "INTERSTITIAL_LOAD_FAILED")
            }
        }
    }

    @objc func isInterstitialReady(_ call: CAPPluginCall) {
        runOnMain {
            call.resolve(["ready": self.interstitialAd != nil])
        }
    }

    @objc func showInterstitial(_ call: CAPPluginCall) {
        runOnMain { self.showInterstitialOnMain(call) }
    }

    @MainActor private func showInterstitialOnMain(_ call: CAPPluginCall) {
        guard let ad = interstitialAd else {
            call.reject("Interstitial ad is not ready", "AD_NOT_READY")
            return
        }
        guard let viewController = bridge?.viewController else {
            call.reject("iOS view controller is unavailable", "VIEW_CONTROLLER_UNAVAILABLE")
            return
        }
        ad.show(from: viewController)
        call.resolve()
    }

    @objc func prepareRewarded(_ call: CAPPluginCall) {
        runOnMain { self.prepareRewardedOnMain(call) }
    }

    @MainActor private func prepareRewardedOnMain(_ call: CAPPluginCall) {
        guard requireInitialized(call), let adUnitID = requireAdUnitID(call) else { return }
        guard !rewardedLoading else {
            call.reject("A rewarded ad load is already in progress", "LOAD_IN_PROGRESS")
            return
        }

        destroyRewardedAd()
        rewardedAdUnitID = adUnitID
        rewardedLoading = true
        rewardedAdLoader.loadAd(with: AdRequest(adUnitID: adUnitID)) { [weak self] result in
            guard let self else { return }
            self.rewardedLoading = false
            switch result {
            case .success(let ad):
                self.rewardedAd = ad
                ad.delegate = self
                self.notifyListeners("rewardedLoaded", data: self.adEvent(adUnitID))
                call.resolve()
            case .failure(let error):
                self.notifyListeners("rewardedFailedToLoad", data: self.errorEvent(adUnitID, error))
                self.reject(call, error: error, code: "REWARDED_LOAD_FAILED")
            }
        }
    }

    @objc func isRewardedReady(_ call: CAPPluginCall) {
        runOnMain {
            call.resolve(["ready": self.rewardedAd != nil])
        }
    }

    @objc func showRewarded(_ call: CAPPluginCall) {
        runOnMain { self.showRewardedOnMain(call) }
    }

    @MainActor private func showRewardedOnMain(_ call: CAPPluginCall) {
        guard let ad = rewardedAd else {
            call.reject("Rewarded ad is not ready", "AD_NOT_READY")
            return
        }
        guard let viewController = bridge?.viewController else {
            call.reject("iOS view controller is unavailable", "VIEW_CONTROLLER_UNAVAILABLE")
            return
        }
        ad.show(from: viewController)
        call.resolve()
    }

    @MainActor private func setBoolean(_ call: CAPPluginCall, setter: (Bool) -> Void) {
        guard let value = call.getBool("value") else {
            call.reject("value is required", "INVALID_ARGUMENT")
            return
        }
        setter(value)
        call.resolve()
    }

    @MainActor private func requireInitialized(_ call: CAPPluginCall) -> Bool {
        guard initialized else {
            call.reject("Call initialize() before loading ads", "NOT_INITIALIZED")
            return false
        }
        return true
    }

    @MainActor private func requireAdUnitID(_ call: CAPPluginCall) -> String? {
        guard let value = call.getString("adUnitId")?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            call.reject("adUnitId is required", "INVALID_ARGUMENT")
            return nil
        }
        return value
    }

    @MainActor private func adEvent(_ adUnitID: String) -> [String: Any] {
        ["adUnitId": adUnitID]
    }

    @MainActor private func errorEvent(_ adUnitID: String, _ error: Error) -> [String: Any] {
        let nsError = error as NSError
        return ["adUnitId": adUnitID, "code": nsError.code, "message": nsError.localizedDescription]
    }

    @MainActor private func reject(_ call: CAPPluginCall, error: Error, code: String) {
        call.reject((error as NSError).localizedDescription, code, error)
    }

    @MainActor private func destroyInterstitialAd() {
        interstitialAd?.delegate = nil
        interstitialAd = nil
    }

    @MainActor private func destroyRewardedAd() {
        rewardedAd?.delegate = nil
        rewardedAd = nil
    }

    private func runOnMain(_ block: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
}

@MainActor extension YandexAdsPlugin: InterstitialAdDelegate {
    public func interstitialAdDidShow(_ interstitialAd: InterstitialAd) {
        notifyListeners("interstitialShown", data: adEvent(interstitialAdUnitID))
    }

    public func interstitialAdDidDismiss(_ interstitialAd: InterstitialAd) {
        notifyListeners("interstitialDismissed", data: adEvent(interstitialAdUnitID))
        destroyInterstitialAd()
    }

    public func interstitialAdDidClick(_ interstitialAd: InterstitialAd) {
        notifyListeners("interstitialClicked", data: adEvent(interstitialAdUnitID))
    }

    public func interstitialAd(_ interstitialAd: InterstitialAd, didTrackImpression impressionData: ImpressionData?) {
        notifyListeners("interstitialImpression", data: adEvent(interstitialAdUnitID))
    }

    public func interstitialAd(_ interstitialAd: InterstitialAd, didFailToShow error: Error) {
        notifyListeners("interstitialFailedToShow", data: errorEvent(interstitialAdUnitID, error))
        destroyInterstitialAd()
    }
}

@MainActor extension YandexAdsPlugin: RewardedAdDelegate {
    public func rewardedAdDidShow(_ rewardedAd: RewardedAd) {
        notifyListeners("rewardedShown", data: adEvent(rewardedAdUnitID))
    }

    public func rewardedAdDidDismiss(_ rewardedAd: RewardedAd) {
        notifyListeners("rewardedDismissed", data: adEvent(rewardedAdUnitID))
        destroyRewardedAd()
    }

    public func rewardedAdDidClick(_ rewardedAd: RewardedAd) {
        notifyListeners("rewardedClicked", data: adEvent(rewardedAdUnitID))
    }

    public func rewardedAd(_ rewardedAd: RewardedAd, didTrackImpression impressionData: ImpressionData?) {
        notifyListeners("rewardedImpression", data: adEvent(rewardedAdUnitID))
    }

    public func rewardedAd(_ rewardedAd: RewardedAd, didReward reward: Reward) {
        notifyListeners("rewarded", data: [
            "adUnitId": rewardedAdUnitID,
            "amount": reward.amount,
            "type": reward.type
        ])
    }

    public func rewardedAd(_ rewardedAd: RewardedAd, didFailToShow error: Error) {
        notifyListeners("rewardedFailedToShow", data: errorEvent(rewardedAdUnitID, error))
        destroyRewardedAd()
    }
}
