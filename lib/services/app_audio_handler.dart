import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import 'audio_service.dart' as mix_service;
import 'storage_service.dart';

/// Bridges the in-app [mix_service.AudioPlayerService] with the platform
/// notification/lock-screen media controls provided by `audio_service`.
class AppAudioHandler extends BaseAudioHandler {
  final mix_service.AudioPlayerService _audioPlayerService;
  late final VoidCallback _serviceListener;

  AppAudioHandler(this._audioPlayerService) {
    _serviceListener = _onServiceStateChanged;
    _audioPlayerService.addListener(_serviceListener);
    _onServiceStateChanged();
  }

  void _onServiceStateChanged() {
    final isPlaying = _audioPlayerService.isMasterPlaying;
    final controls = isPlaying
        ? [MediaControl.pause, MediaControl.stop]
        : [MediaControl.play, MediaControl.stop];
    final systemActions = isPlaying
        ? const {MediaAction.pause, MediaAction.stop}
        : const {MediaAction.play, MediaAction.stop};

    playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.ready,
        playing: isPlaying,
        systemActions: systemActions,
        updateTime: DateTime.now(),
      ),
    );

    final playingMap = _audioPlayerService.playingStates;
    final activeIds = _audioPlayerService.activeSoundIds
        .where((id) => playingMap[id] == true)
        .toList(growable: false);

    if (activeIds.isEmpty) {
      queue.add(<MediaItem>[]);
      mediaItem.add(null);
      AudioService.stop();
      return;
    }

    final queueItems = activeIds.map((id) {
      final sound = StorageService.getSound(id);
      return MediaItem(
        id: id,
        title: sound?.name ?? 'Ambience',
        artist: sound?.category ?? 'Arcadia',
        album: 'Arcadia',
        extras: {'category': sound?.category},
      );
    }).toList(growable: false);

    queue.add(queueItems);

    final summaryTitle = queueItems.map((item) => item.title).join(' • ');
    mediaItem.add(
      MediaItem(
        id: 'arcadia_mix',
        title: summaryTitle,
        artist: 'Arcadia Ambient Mix',
        album: 'Arcadia',
        extras: {'activeSoundIds': activeIds},
      ),
    );
  }

  @override
  Future<void> play() async {
    await _audioPlayerService.resumeAll();
    _onServiceStateChanged();
  }

  @override
  Future<void> pause() async {
    await _audioPlayerService.pauseAll();
    _onServiceStateChanged();
  }

  @override
  Future<void> stop() async {
    await _audioPlayerService.stopAll();
    _onServiceStateChanged();
    await super.stop();
  }
}

