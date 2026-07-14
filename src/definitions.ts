import type { PluginListenerHandle } from '@capacitor/core';

export interface InitializeOptions {
  userConsent?: boolean;
  ageRestricted?: boolean;
  locationTracking?: boolean;
  enableLogging?: boolean;
}

export interface InitializeResult {
  version: string;
}

export interface BooleanValue {
  value: boolean;
}

export interface AdLoadOptions {
  adUnitId: string;
}

export interface BannerResult {
  width: number;
  height: number;
}

export interface AdReadyResult {
  ready: boolean;
}

export interface FullscreenAdResult {
  presented: boolean;
}

export interface RewardedAdResult extends FullscreenAdResult {
  rewarded: boolean;
}

export interface AdEvent {
  adUnitId: string;
}

export interface AdErrorEvent extends AdEvent {
  code?: number;
  message: string;
}

export interface RewardEvent extends AdEvent {
  amount: number;
  type: string;
}

export type YandexAdsEventName =
  | 'bannerLoaded'
  | 'bannerClicked'
  | 'bannerImpression'
  | 'bannerFailedToLoad'
  | 'interstitialLoaded'
  | 'interstitialShown'
  | 'interstitialClicked'
  | 'interstitialImpression'
  | 'interstitialDismissed'
  | 'interstitialFailedToLoad'
  | 'interstitialFailedToShow'
  | 'rewardedLoaded'
  | 'rewardedShown'
  | 'rewardedClicked'
  | 'rewardedImpression'
  | 'rewardedDismissed'
  | 'rewardedFailedToLoad'
  | 'rewardedFailedToShow'
  | 'rewarded';

export interface YandexAdsPlugin {
  initialize(options?: InitializeOptions): Promise<InitializeResult>;
  setUserConsent(options: BooleanValue): Promise<void>;
  setAgeRestricted(options: BooleanValue): Promise<void>;
  setLocationTracking(options: BooleanValue): Promise<void>;
  showBanner(options: AdLoadOptions): Promise<BannerResult>;
  removeBanner(): Promise<void>;
  prepareInterstitial(options: AdLoadOptions): Promise<void>;
  isInterstitialReady(): Promise<AdReadyResult>;
  showInterstitial(): Promise<FullscreenAdResult>;
  prepareRewarded(options: AdLoadOptions): Promise<void>;
  isRewardedReady(): Promise<AdReadyResult>;
  showRewarded(): Promise<RewardedAdResult>;

  addListener(eventName: 'rewarded', listenerFunc: (event: RewardEvent) => void): Promise<PluginListenerHandle>;
  addListener(
    eventName:
      'interstitialFailedToLoad' | 'interstitialFailedToShow' | 'rewardedFailedToLoad' | 'rewardedFailedToShow',
    listenerFunc: (event: AdErrorEvent) => void,
  ): Promise<PluginListenerHandle>;
  addListener(eventName: YandexAdsEventName, listenerFunc: (event: AdEvent) => void): Promise<PluginListenerHandle>;
  removeAllListeners(): Promise<void>;
}
