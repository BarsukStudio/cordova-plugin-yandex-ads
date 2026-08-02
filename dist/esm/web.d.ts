import { WebPlugin } from '@capacitor/core';
import type { AdReadyResult, BannerResult, FullscreenAdResult, InitializeResult, RewardedAdResult, YandexAdsPlugin } from './definitions';
export declare class YandexAdsWeb extends WebPlugin implements YandexAdsPlugin {
    private nativeOnly;
    initialize(): Promise<InitializeResult>;
    setUserConsent(): Promise<void>;
    setAgeRestricted(): Promise<void>;
    setLocationTracking(): Promise<void>;
    showBanner(): Promise<BannerResult>;
    removeBanner(): Promise<void>;
    prepareInterstitial(): Promise<void>;
    isInterstitialReady(): Promise<AdReadyResult>;
    showInterstitial(): Promise<FullscreenAdResult>;
    prepareRewarded(): Promise<void>;
    isRewardedReady(): Promise<AdReadyResult>;
    showRewarded(): Promise<RewardedAdResult>;
}
