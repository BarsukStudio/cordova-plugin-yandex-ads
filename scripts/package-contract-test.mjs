#!/usr/bin/env node
import assert from 'node:assert/strict';
import fs from 'node:fs';

const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const androidBuild = fs.readFileSync('android/build.gradle', 'utf8');
const podspec = fs.readFileSync('CapacitorPluginYandexAds.podspec', 'utf8');
const swiftPackage = fs.readFileSync('Package.swift', 'utf8');
const definitions = fs.readFileSync('src/definitions.ts', 'utf8');
const readme = fs.readFileSync('README.md', 'utf8');

assert.equal(packageJson.name, 'capacitor-plugin-yandex-ads');
assert.equal(
  packageJson.repository?.url,
  'https://github.com/BarsukStudio/capacitor-plugin-yandex-ads.git',
);
assert.equal(packageJson.scripts?.prepare, 'npm run build');
assert.ok(packageJson.files?.includes('dist/'));

assert.match(androidBuild, /com\.yandex\.android:mobileads:8\.2\.0/);
assert.match(podspec, /s\.dependency 'YandexMobileAds', '8\.2\.1'/);
assert.match(swiftPackage, /yandex-ads-sdk-ios\.git", exact: "8\.2\.0"/);

assert.match(definitions, /interface BannerResult \{\s*adUnitId: string;/);
assert.match(
  definitions,
  /eventName:[\s\S]{0,120}'bannerFailedToLoad'[\s\S]{0,240}listenerFunc: \(event: AdErrorEvent\)/,
);

assert.match(readme, /BarsukStudio\/capacitor-plugin-yandex-ads\.git/);
assert.doesNotMatch(readme, /BarsukStudio\/cordova-plugin-yandex-ads/);
assert.match(readme, /userConsent: false/);

console.log('Yandex Ads package contract checks passed.');
