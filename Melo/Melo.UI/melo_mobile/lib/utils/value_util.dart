import 'package:melo_mobile/models/song_response.dart';

class ValueUtil {
  static bool arePlaylistsEqual(List<SongResponse>? a, List<SongResponse>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
