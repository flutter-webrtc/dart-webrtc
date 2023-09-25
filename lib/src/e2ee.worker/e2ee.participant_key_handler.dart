import 'dart:async';
import 'dart:html';
import 'dart:js_util' as jsutil;
import 'dart:typed_data';

import 'crypto.dart' as crypto;
import 'e2ee.cryptor.dart';
import 'e2ee.utils.dart';

class KeyProviderOptions {
  KeyProviderOptions({
    required this.sharedKey,
    required this.ratchetSalt,
    required this.ratchetWindowSize,
    this.uncryptedMagicBytes,
    this.failureTolerance = -1,
  });
  bool sharedKey;
  Uint8List ratchetSalt;
  int ratchetWindowSize;
  int failureTolerance;
  Uint8List? uncryptedMagicBytes;

  @override
  String toString() {
    return 'KeyOptions{sharedKey: $sharedKey, ratchetWindowSize: $ratchetWindowSize}';
  }
}

class ParticipantKeyHandler {
  ParticipantKeyHandler(this.keyProviderOptions, this.participantIdentity);

  int currentKeyIndex = 0;

  List<KeySet> cryptoKeyRing = [];

  KeyProviderOptions keyProviderOptions;

  String? participantIdentity;

  int decryptionFailureCount = 0;

  bool _hasValidKey = true;

  bool get hasValidKey => _hasValidKey;

  void decryptionFailure() {
    if (keyProviderOptions.failureTolerance < 0) {
      return;
    }
    decryptionFailureCount += 1;

    if (decryptionFailureCount > keyProviderOptions.failureTolerance) {
      _hasValidKey = false;
    }
  }

  void decryptionSuccess() {
    resetKeyStatus();
  }

  void resetKeyStatus() {
    decryptionFailureCount = 0;
    _hasValidKey = true;
  }

  Future<KeySet> ratchetKey(int? keyIndex, {bool setKey = true}) async {
    var keySet = getKeySet(keyIndex);
    if (keySet == null) {
      throw Exception('Key not found');
    }
    var newMaterial = await ratchetMaterial(keySet.material);
    var newKeySet =
        await deriveKeys(newMaterial, keyProviderOptions.ratchetSalt);
    if (setKey) {
      await setKeySetFromMaterial(newKeySet, keyIndex ?? currentKeyIndex);
    }
    return newKeySet;
  }

  Future<Uint8List> ratchet(CryptoKey material, Uint8List salt) async {
    var algorithmOptions = getAlgoOptions('PBKDF2', salt);

    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/deriveBits
    var newKey = await jsutil.promiseToFuture<ByteBuffer>(
        crypto.deriveBits(jsutil.jsify(algorithmOptions), material, 256));
    return newKey.asUint8List();
  }

  Future<CryptoKey> ratchetMaterial(CryptoKey currentMaterial) async {
    var newMaterial = await jsutil.promiseToFuture(crypto.importKey(
      'raw',
      crypto.jsArrayBufferFrom(
          await ratchet(currentMaterial, keyProviderOptions.ratchetSalt)),
      (currentMaterial.algorithm as crypto.Algorithm).name,
      false,
      ['deriveBits', 'deriveKey'],
    ));
    return newMaterial;
  }

  Future<void> setKey(Uint8List key, {int keyIndex = 0}) async {
    var keyMaterial = await crypto.impportKeyFromRawData(key,
        webCryptoAlgorithm: 'PBKDF2', keyUsages: ['deriveBits', 'deriveKey']);
    var keySet = await deriveKeys(
      keyMaterial,
      keyProviderOptions.ratchetSalt,
    );
    await setKeySetFromMaterial(keySet, keyIndex);
    resetKeyStatus();
  }

  Future<void> setKeySetFromMaterial(KeySet keySet, int keyIndex) async {
    print('setting new key');
    if (keyIndex >= 0) {
      currentKeyIndex = keyIndex % cryptoKeyRing.length;
    }
    cryptoKeyRing[currentKeyIndex] = keySet;
  }

  /// Derives a set of keys from the master key.
  /// See https://tools.ietf.org/html/draft-omara-sframe-00#section-4.3.1
  Future<KeySet> deriveKeys(CryptoKey material, Uint8List salt) async {
    var algorithmOptions =
        getAlgoOptions((material.algorithm as crypto.Algorithm).name, salt);

    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/deriveKey#HKDF
    // https://developer.mozilla.org/en-US/docs/Web/API/HkdfParams
    var encryptionKey =
        await jsutil.promiseToFuture<CryptoKey>(crypto.deriveKey(
      jsutil.jsify(algorithmOptions),
      material,
      jsutil.jsify({'name': 'AES-GCM', 'length': 128}),
      false,
      ['encrypt', 'decrypt'],
    ));

    return KeySet(material, encryptionKey);
  }

  void setCurrentKeyIndex(int index) {
    currentKeyIndex = index % cryptoKeyRing.length;
    resetKeyStatus();
  }

  int getCurrentKeyIndex() {
    return currentKeyIndex;
  }

  KeySet? getKeySet([int? keyIndex]) {
    return cryptoKeyRing[keyIndex ?? currentKeyIndex];
  }
}
