import '../../../resources/assets/app_images.dart';

final class ChatMessage {
  /// `null` for the messages of the user.
  final String? author;
  final String? text;
  final AppImage? image;

  /// How many people left each reaction.
  final Map<String, int> reactions;

  ChatMessage({this.author, this.text, this.image, Map<String, int>? reactions})
    : assert(text != null || image != null),
      reactions = reactions ?? {};

  bool get isMine => author == null;

  int get reactionCount =>
      reactions.values.fold(0, (sum, count) => sum + count);
}
