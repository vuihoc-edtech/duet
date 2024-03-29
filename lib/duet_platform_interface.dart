import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'duet_method_channel.dart';

abstract class DuetPlatform extends PlatformInterface {
  /// Constructs a DuetPlatform.
  DuetPlatform() : super(token: _token);

  static final Object _token = Object();

  static DuetPlatform _instance = MethodChannelDuet();

  /// The default instance of [DuetPlatform] to use.
  ///
  /// Defaults to [MethodChannelDuet].
  static DuetPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DuetPlatform] when
  /// they register themselves.
  static set instance(DuetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> onNativeCall({
    OnVideoRecorded? onVideoRecorded,
    OnAudioReceived? onAudioReceived,
    OnVideoMerged? onVideoMerged,
    OnTimerVideoReceived? onTimerVideoReceived,
    OnVideoError? onVideoError,
    OnWillEnterForeground? onWillEnterForeground,
    OnVideoError? onAlert,
    OnAudioFinish? onAudioFinish,
    OnStopAudioPlayer? onStopAudioPlayer,
  });

  Future<String?> recordDuet();

  Future<String?> pauseDuet();

  Future<String?> resumeDuet();

  Future<String?> recordAudio();

  Future<String?> pauseAudio();

  Future<bool?> playSound(String url);

  Future<bool?> playAudioFromUrl(String path);

  Future<String?> stopAudioPlayer();

  Future<String?> retryMerge(String url);

  Future<String?> reset();
}
