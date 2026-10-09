import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has English defaults', () {
    const labels = SmartContextMenuLabels();

    expect(labels.back, 'Back');
    expect(labels.retry, 'Try again');
    expect(labels.loading, 'Loading…');
    expect(labels.error, 'Could not load');
    expect(labels.empty, 'No items');
  });
}
