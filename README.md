# capacitor-plugin-yandex-ads

Native Capacitor 8 plugin for Yandex Mobile Ads SDK 8.2.0 on Android and iOS.

Supported in the first release:

- sticky banner ads;
- interstitial ads;
- rewarded ads;
- load/show lifecycle events;
- user consent, age restriction, and location-tracking privacy flags.

The plugin intentionally contains no Cordova hooks, launcher activities, or `MainActivity` replacement.

## Requirements

- Capacitor 8;
- Android `minSdkVersion` 24 or newer and `compileSdkVersion` 35 or newer;
- iOS 15 or newer;
- Xcode 16.4 or newer.

## Install

Until the package is published to npm, install it directly from this repository:

```bash
npm install github:BarsukStudio/cordova-plugin-yandex-ads
npx cap sync
```

For local development:

```bash
npm install /absolute/path/to/cordova-plugin-yandex-ads
npx cap sync
```

On iOS, add the current Yandex `SKAdNetworkItems` list to the app's `Info.plist`. The SDK dependency itself is installed automatically by CocoaPods or Swift Package Manager.

## Usage

```ts
import { YandexAds } from 'capacitor-plugin-yandex-ads';

await YandexAds.addListener('rewarded', ({ amount, type }) => {
  // Grant the reward only here.
  console.info('Reward earned', amount, type);
});

await YandexAds.initialize({
  userConsent: true,
  ageRestricted: false,
  locationTracking: false,
});

await YandexAds.showBanner({ adUnitId: 'demo-banner-yandex' });
await YandexAds.prepareInterstitial({ adUnitId: 'demo-interstitial-yandex' });
await YandexAds.showInterstitial();

await YandexAds.prepareRewarded({ adUnitId: 'demo-rewarded-yandex' });
await YandexAds.showRewarded();
```

`prepareInterstitial()` and `prepareRewarded()` resolve only after an ad has loaded. `showInterstitial()` and `showRewarded()` only start presentation; use lifecycle events for the actual result. Never grant a reward from the `showRewarded()` promise—grant it only from the `rewarded` event.

The web implementation reports the plugin as unavailable. Route browser builds to a web ad provider before calling this API.

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`setUserConsent(...)`](#setuserconsent)
* [`setAgeRestricted(...)`](#setagerestricted)
* [`setLocationTracking(...)`](#setlocationtracking)
* [`showBanner(...)`](#showbanner)
* [`removeBanner()`](#removebanner)
* [`prepareInterstitial(...)`](#prepareinterstitial)
* [`isInterstitialReady()`](#isinterstitialready)
* [`showInterstitial()`](#showinterstitial)
* [`prepareRewarded(...)`](#preparerewarded)
* [`isRewardedReady()`](#isrewardedready)
* [`showRewarded()`](#showrewarded)
* [`addListener('rewarded', ...)`](#addlistenerrewarded-)
* [`addListener('interstitialFailedToLoad' | 'interstitialFailedToShow' | 'rewardedFailedToLoad' | 'rewardedFailedToShow', ...)`](#addlistenerinterstitialfailedtoload--interstitialfailedtoshow--rewardedfailedtoload--rewardedfailedtoshow-)
* [`addListener(YandexAdsEventName, ...)`](#addlisteneryandexadseventname-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options?: InitializeOptions | undefined) => Promise<InitializeResult>
```

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#initializeresult">InitializeResult</a>&gt;</code>

--------------------


### setUserConsent(...)

```typescript
setUserConsent(options: BooleanValue) => Promise<void>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#booleanvalue">BooleanValue</a></code> |

--------------------


### setAgeRestricted(...)

```typescript
setAgeRestricted(options: BooleanValue) => Promise<void>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#booleanvalue">BooleanValue</a></code> |

--------------------


### setLocationTracking(...)

```typescript
setLocationTracking(options: BooleanValue) => Promise<void>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#booleanvalue">BooleanValue</a></code> |

--------------------


### showBanner(...)

```typescript
showBanner(options: AdLoadOptions) => Promise<BannerResult>
```

| Param         | Type                                                    |
| ------------- | ------------------------------------------------------- |
| **`options`** | <code><a href="#adloadoptions">AdLoadOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#bannerresult">BannerResult</a>&gt;</code>

--------------------


### removeBanner()

```typescript
removeBanner() => Promise<void>
```

--------------------


### prepareInterstitial(...)

```typescript
prepareInterstitial(options: AdLoadOptions) => Promise<void>
```

| Param         | Type                                                    |
| ------------- | ------------------------------------------------------- |
| **`options`** | <code><a href="#adloadoptions">AdLoadOptions</a></code> |

--------------------


### isInterstitialReady()

```typescript
isInterstitialReady() => Promise<AdReadyResult>
```

**Returns:** <code>Promise&lt;<a href="#adreadyresult">AdReadyResult</a>&gt;</code>

--------------------


### showInterstitial()

```typescript
showInterstitial() => Promise<void>
```

--------------------


### prepareRewarded(...)

```typescript
prepareRewarded(options: AdLoadOptions) => Promise<void>
```

| Param         | Type                                                    |
| ------------- | ------------------------------------------------------- |
| **`options`** | <code><a href="#adloadoptions">AdLoadOptions</a></code> |

--------------------


### isRewardedReady()

```typescript
isRewardedReady() => Promise<AdReadyResult>
```

**Returns:** <code>Promise&lt;<a href="#adreadyresult">AdReadyResult</a>&gt;</code>

--------------------


### showRewarded()

```typescript
showRewarded() => Promise<void>
```

--------------------


### addListener('rewarded', ...)

```typescript
addListener(eventName: 'rewarded', listenerFunc: (event: RewardEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                    |
| ------------------ | ----------------------------------------------------------------------- |
| **`eventName`**    | <code>'rewarded'</code>                                                 |
| **`listenerFunc`** | <code>(event: <a href="#rewardevent">RewardEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('interstitialFailedToLoad' | 'interstitialFailedToShow' | 'rewardedFailedToLoad' | 'rewardedFailedToShow', ...)

```typescript
addListener(eventName: 'interstitialFailedToLoad' | 'interstitialFailedToShow' | 'rewardedFailedToLoad' | 'rewardedFailedToShow', listenerFunc: (event: AdErrorEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'interstitialFailedToLoad' \| 'interstitialFailedToShow' \| 'rewardedFailedToLoad' \| 'rewardedFailedToShow'</code> |
| **`listenerFunc`** | <code>(event: <a href="#aderrorevent">AdErrorEvent</a>) =&gt; void</code>                                                 |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener(YandexAdsEventName, ...)

```typescript
addListener(eventName: YandexAdsEventName, listenerFunc: (event: AdEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                              |
| ------------------ | ----------------------------------------------------------------- |
| **`eventName`**    | <code><a href="#yandexadseventname">YandexAdsEventName</a></code> |
| **`listenerFunc`** | <code>(event: <a href="#adevent">AdEvent</a>) =&gt; void</code>   |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### InitializeResult

| Prop          | Type                |
| ------------- | ------------------- |
| **`version`** | <code>string</code> |


#### InitializeOptions

| Prop                   | Type                 |
| ---------------------- | -------------------- |
| **`userConsent`**      | <code>boolean</code> |
| **`ageRestricted`**    | <code>boolean</code> |
| **`locationTracking`** | <code>boolean</code> |
| **`enableLogging`**    | <code>boolean</code> |


#### BooleanValue

| Prop        | Type                 |
| ----------- | -------------------- |
| **`value`** | <code>boolean</code> |


#### BannerResult

| Prop         | Type                |
| ------------ | ------------------- |
| **`width`**  | <code>number</code> |
| **`height`** | <code>number</code> |


#### AdLoadOptions

| Prop           | Type                |
| -------------- | ------------------- |
| **`adUnitId`** | <code>string</code> |


#### AdReadyResult

| Prop        | Type                 |
| ----------- | -------------------- |
| **`ready`** | <code>boolean</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### RewardEvent

| Prop         | Type                |
| ------------ | ------------------- |
| **`amount`** | <code>number</code> |
| **`type`**   | <code>string</code> |


#### AdErrorEvent

| Prop          | Type                |
| ------------- | ------------------- |
| **`code`**    | <code>number</code> |
| **`message`** | <code>string</code> |


#### AdEvent

| Prop           | Type                |
| -------------- | ------------------- |
| **`adUnitId`** | <code>string</code> |


### Type Aliases


#### YandexAdsEventName

<code>'bannerLoaded' | 'bannerClicked' | 'bannerImpression' | 'bannerFailedToLoad' | 'interstitialLoaded' | 'interstitialShown' | 'interstitialClicked' | 'interstitialImpression' | 'interstitialDismissed' | 'interstitialFailedToLoad' | 'interstitialFailedToShow' | 'rewardedLoaded' | 'rewardedShown' | 'rewardedClicked' | 'rewardedImpression' | 'rewardedDismissed' | 'rewardedFailedToLoad' | 'rewardedFailedToShow' | 'rewarded'</code>

</docgen-api>
