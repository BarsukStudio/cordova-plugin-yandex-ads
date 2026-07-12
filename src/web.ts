import { WebPlugin } from '@capacitor/core';

import type { AdReadyResult, InitializeResult, YandexAdsPlugin } from './definitions';

export class YandexAdsWeb extends WebPlugin implements YandexAdsPlugin {
  private nativeOnly(): never {
    throw this.unimplemented('Yandex Mobile Ads is available only on Android and iOS.');
  }

  async initialize(): Promise<InitializeResult> {
    return this.nativeOnly();
  }

  async setUserConsent(): Promise<void> {
    return this.nativeOnly();
  }

  async setAgeRestricted(): Promise<void> {
    return this.nativeOnly();
  }

  async setLocationTracking(): Promise<void> {
    return this.nativeOnly();
  }

  async prepareInterstitial(): Promise<void> {
    return this.nativeOnly();
  }

  async isInterstitialReady(): Promise<AdReadyResult> {
    return { ready: false };
  }

  async showInterstitial(): Promise<void> {
    return this.nativeOnly();
  }

  async prepareRewarded(): Promise<void> {
    return this.nativeOnly();
  }

  async isRewardedReady(): Promise<AdReadyResult> {
    return { ready: false };
  }

  async showRewarded(): Promise<void> {
    return this.nativeOnly();
  }
}
