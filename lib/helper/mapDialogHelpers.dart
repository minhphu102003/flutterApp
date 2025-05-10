import 'package:flutter/material.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/widgets/placeInfor.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:latlong2/latlong.dart';

typedef OnDirectionPressed = void Function(LatLng, LatLng);

void showPlaceInfoDialog({
  required BuildContext context,
  required Place place,
  required LatLng currentLocation,
  required OnDirectionPressed onDirectionPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return PlaceInfoWidget(
        place: place,
        currentLocation: currentLocation,
        onDirectionPressed: onDirectionPressed,
      );
    },
  );
}

void showYoutubeDialog({
  required BuildContext context,
  required String youtubeUrl,
}) {
  final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
  if (videoId == null) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Invalid YouTube URL"),
        content: Text("Cannot load video."),
      ),
    );
    return;
  }

  final YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
    ),
  );

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(8),
      content: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
        ),
      ),
    ),
  ).then((_) {
    controller.pause();
    controller.dispose();
  });
}
