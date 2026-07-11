import 'package:devil_run/levels/level_catalog.dart';
import 'package:devil_run/models/level_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all bundled catalog levels pass structural validation', () {
    for (final level in LevelCatalog.levels) {
      expect(level.validate, returnsNormally, reason: 'Level ${level.id}');
    }
  });

  test('invalid JSON reports a useful level definition error', () {
    expect(
      () => LevelDefinition.fromJsonText('{"id": 1}'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('Invalid level definition'),
        ),
      ),
    );
  });

  test('validation rejects duplicate ids, missing targets, and wrong door', () {
    const prefix = '''
      "id": 1,
      "name": "Broken",
      "size": {"w": 400, "h": 200},
      "spawn": {"x": 20, "y": 20},
    ''';
    final invalidBodies = [
      '''"doorId":"door","entities":[
        {"id":"door","kind":"door","rect":{"x":300,"y":20,"w":40,"h":60}},
        {"id":"door","kind":"platform","rect":{"x":0,"y":100,"w":400,"h":100}}
      ]''',
      '''"doorId":"door","entities":[
        {"id":"door","kind":"door","rect":{"x":300,"y":20,"w":40,"h":60}},
        {"id":"trigger","kind":"trigger","rect":{"x":0,"y":0,"w":50,"h":50},"triggerAction":"vanishTarget","targetId":"missing"}
      ]''',
      '''"doorId":"floor","entities":[
        {"id":"floor","kind":"platform","rect":{"x":0,"y":100,"w":400,"h":100}}
      ]''',
    ];

    for (final body in invalidBodies) {
      expect(
        () => LevelDefinition.fromJsonText('{$prefix$body}'),
        throwsFormatException,
      );
    }
  });
}
