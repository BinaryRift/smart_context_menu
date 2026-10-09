import '../../../resources/assets/app_images.dart';
import 'chat_message.dart';

/// The messages of the chat, oldest first.
List<ChatMessage> demoMessages() => [
  ChatMessage(author: 'Anna', text: 'Who is coming on Saturday?'),
  ChatMessage(text: 'Me! Where do we meet?', reactions: {'👍': 2}),
  ChatMessage(
    author: 'Boris',
    text: 'At the station at 8. This is where we are going:',
  ),
  ChatMessage(
    author: 'Boris',
    image: AppImages.lake,
    reactions: {'👍': 180, '❤️': 60},
  ),
  ChatMessage(
    author: 'Chris',
    text:
        'Last time we took the trail along the river, and it was muddy '
        'after the rain, so bring proper boots. The view from the top is '
        'worth it, and on the way down there is a waterfall where we can '
        'stop for lunch.',
  ),
  ChatMessage(
    author: 'Chris',
    image: AppImages.waterfall,
    reactions: {'😮': 12},
  ),
  ChatMessage(text: 'I am in. I will bring snacks for everyone'),
];

/// The chats a message can be forwarded to.
const chats = ['Family', 'Work', 'Running club', 'Anna', 'Boris'];

/// The members who have seen the messages of the user.
const readers = ['Anna', 'Boris', 'Chris', 'Diana'];

const _firstNames = ['Anna', 'Boris', 'Chris', 'Diana', 'Emma', 'Felix'];
const _lastNames = ['Adams', 'Brown', 'Clark', 'Davis', 'Evans', 'Ford'];

/// The name of the [index]-th person who reacted to a message.
String personName(int index) {
  final first = _firstNames[index % _firstNames.length];
  final last = _lastNames[index ~/ _firstNames.length % _lastNames.length];
  return '$first $last';
}

/// The reaction of the [index]-th person who reacted to [message].
String reactionAt(ChatMessage message, int index) {
  var rest = index;
  for (final MapEntry(key: reaction, value: count)
      in message.reactions.entries) {
    if (rest < count) return reaction;
    rest -= count;
  }
  throw RangeError.index(index, message.reactions);
}
