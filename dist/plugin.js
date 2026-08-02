var capacitorYandexAds = (function (exports, core) {
    'use strict';

    const YandexAds = core.registerPlugin('YandexAds', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.YandexAdsWeb()),
    });

    class YandexAdsWeb extends core.WebPlugin {
        nativeOnly() {
            throw this.unimplemented('Yandex Mobile Ads is available only on Android and iOS.');
        }
        async initialize() {
            return this.nativeOnly();
        }
        async setUserConsent() {
            return this.nativeOnly();
        }
        async setAgeRestricted() {
            return this.nativeOnly();
        }
        async setLocationTracking() {
            return this.nativeOnly();
        }
        async showBanner() {
            return this.nativeOnly();
        }
        async removeBanner() {
            return this.nativeOnly();
        }
        async prepareInterstitial() {
            return this.nativeOnly();
        }
        async isInterstitialReady() {
            return { ready: false };
        }
        async showInterstitial() {
            return this.nativeOnly();
        }
        async prepareRewarded() {
            return this.nativeOnly();
        }
        async isRewardedReady() {
            return { ready: false };
        }
        async showRewarded() {
            return this.nativeOnly();
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        YandexAdsWeb: YandexAdsWeb
    });

    exports.YandexAds = YandexAds;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
