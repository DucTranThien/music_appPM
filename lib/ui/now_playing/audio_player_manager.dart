import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  // Singleton instance
  AudioPlayerManager._internal();

  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  factory AudioPlayerManager() => _instance;

  final player = AudioPlayer(); // Đối tượng AudioPlayer để phát nhạc
  Stream<DurationState>? durationState; // Stream để theo dõi trạng thái tiến trình bài hát
  String songUrl = ""; // URL của bài hát hiện tại

  // Phương thức chuẩn bị bài hát (set URL và theo dõi tiến trình phát)
  Future<void> prepare({bool isNewSong = false}) async {
    // Theo dõi vị trí và tiến trình bài hát
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
          (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );

    // Nếu là bài hát mới, set lại URL
    if (isNewSong) {
      await player.setUrl(songUrl); // Đảm bảo setUrl hoàn thành trước khi tiếp tục
    }
  }

  // Cập nhật URL của bài hát và chuẩn bị
  void updateSongUrl(String url) {
    songUrl = url; // Cập nhật URL bài hát
    prepare(isNewSong: true); // Gọi prepare để tải bài hát mới
  }

  // Hủy tài nguyên khi không cần thiết nữa
  void dispose() {
    player.dispose(); // Giải phóng tài nguyên của AudioPlayer
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress; // Tiến trình hiện tại của bài hát
  final Duration buffered; // Vị trí đã được tải trong bài hát
  final Duration? total; // Tổng thời gian của bài hát
}
