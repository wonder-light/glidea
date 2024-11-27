import 'package:flutter_test/flutter_test.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/render.dart';

import './render_test.reflectable.dart' show initializeReflectable;

void main() {
  initializeReflectable();
  JsonHelp.initialized();
  final TJsonMap inputMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'input',
    'value': '=========',
    'note': '帮助文本',
    'hint': '提示文本',
    'card': 'test',
  };
  final TJsonMap selectMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'select',
    'value': '=========',
    'note': '帮助文本',
    'options': [
      {'label': '测试1', 'value': 'test1'},
      {'label': '测试2', 'value': 'test2'},
    ],
  };
  final TJsonMap radioMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'radio',
    'value': '=========',
    'note': '帮助文本',
    'options': [
      {
        "label": "选项显示名称",
        "value": "选项对应值",
      },
    ],
  };
  final TJsonMap toggleMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'toggle',
    'value': true,
    'note': '帮助文本',
  };
  final TJsonMap sliderMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'slider',
    'value': 0,
    'max': 100,
    'note': '帮助文本',
  };
  final TJsonMap arrayMaps = {
    'name': 'test',
    'label': '测试',
    'type': 'array',
    'value': [],
    'note': '帮助文本',
    'arrayItems': [
      inputMaps,
      selectMaps,
      radioMaps,
      toggleMaps,
      sliderMaps,
    ],
  };


  group('测试 InputConfig', (){
    test('InputConfig toJson 测试', () async {
      var config = InputConfig();
      TJsonMap str = {};

      expect(config.value, '');

      expect(config.toJson(), isNotEmpty);

      expect(str = config.toMap()!, isNotNull);

      expect(str['type'], FieldType.input);

      expect(str['value'], isEmpty);
    });
    test('InputConfig fromJson 测试', () async {
      String str = '';

      late InputConfig config;

      expect(str = inputMaps.toJson(), isNotEmpty);

      expect(str.fromJson<ConfigBase>() is InputConfig, isTrue);

      expect(config = str.fromJson<InputConfig>()!, isNotNull);

      expect(config.group, '');
      expect(config.card, InputCardType.none);
      expect(config.name, inputMaps['name']);
      expect(config.type.name, inputMaps['type']);
      expect(config.label, inputMaps['label']);
      expect(config.value, inputMaps['value']);
    });
  });

  group('测试 SelectConfig', (){
    test('SelectConfig toJson 测试', () async {
      var config = SelectConfig();
      TJsonMap str = {};

      expect(config.toJson(), isNotEmpty);

      expect(str = config.toMap()!, isNotNull);

      expect(str['type'], FieldType.select);

      expect(str['options'], isEmpty);
    });
    test('SelectConfig fromJson 测试', () async {
      String str = '';

      late SelectConfig config;

      expect(str = selectMaps.toJson(), isNotEmpty);

      expect(str.fromJson<ConfigBase>() is SelectConfig, isTrue);

      expect(config = str.fromJson<SelectConfig>()!, isNotNull);

      expect(config.name, selectMaps['name']);
      expect(config.type, FieldType.select);
      expect(config.options, isNotEmpty);
    });
  });

  group('测试 RadioConfig', (){
    test('RadioConfig toJson 测试', () async {
      var config = RadioConfig();
      TJsonMap str = {};

      expect(config.options, isNotNull);

      expect(config.toJson(), isNotEmpty);

      expect(str = config.toMap()!, isNotNull);

      expect(str['type'], FieldType.radio);

      expect(str['options'], isEmpty);
    });
    test('RadioConfig fromJson 测试', () async {
      String str = '';

      late RadioConfig config;

      expect(str = radioMaps.toJson(), isNotEmpty);

      expect(str.fromJson<ConfigBase>() is RadioConfig, isTrue);

      expect(config = str.fromJson<RadioConfig>()!, isNotNull);

      expect(config.group, '');
      expect(config.name, radioMaps['name']);
      expect(config.label, radioMaps['label']);
      expect(config.value, radioMaps['value']);
      expect(config.options, isNotEmpty);
      expect(config.options[0].label, radioMaps['options'][0]['label']);
      expect(config.options[0].value, radioMaps['options'][0]['value']);
    });
  });

  group('测试 ToggleConfig', (){
    test('ToggleConfig toJson 测试', () async {
      var config = ToggleConfig();
      TJsonMap str = {};

      expect(config.toJson(), isNotEmpty);

      expect(str = config.toMap()!, isNotNull);

      expect(str['type'], FieldType.toggle);
    });
    test('ToggleConfig fromJson 测试', () async {
      String str = '';

      late ToggleConfig config;

      expect(str = toggleMaps.toJson(), isNotEmpty);
      expect(str.fromJson<ConfigBase>() is ToggleConfig, isTrue);
      expect(config = str.fromJson<ToggleConfig>()!, isNotNull);

      var maps = toggleMaps.mergeMaps({'type': 'switch'});

      expect(str = toggleMaps.toJson(), isNotEmpty);
      expect(str.fromJson<ConfigBase>() is ToggleConfig, isTrue);
      expect(config = str.fromJson<ToggleConfig>()!, isNotNull);

      expect(config.name, maps['name']);
      expect(config.label, maps['label']);
      expect(config.value, maps['value']);
      expect(config.type, FieldType.toggle);
    });
  });

  group('测试 ArrayConfig', (){
    test('ArrayConfig toJson 测试', () async {
      var config = ArrayConfig();
      TJsonMap str = {};

      expect(config.toJson(), isNotEmpty);

      expect(str = config.toMap()!, isNotNull);

      expect(str['type'], FieldType.array);
      expect(str['arrayItems'], isEmpty);
    });
    test('ArrayConfig fromJson 测试', () async {
      String str = '';

      late ArrayConfig config;

      expect(str = arrayMaps.toJson(), isNotEmpty);
      expect(str.fromJson<ConfigBase>() is ArrayConfig, isTrue);
      expect(config = str.fromJson<ArrayConfig>()!, isNotNull);

      expect(config.arrayItems, isNotEmpty);
      expect(config.arrayItems[0] is InputConfig, isTrue);
      expect(config.arrayItems[1] is SelectConfig, isTrue);
      expect(config.arrayItems[2] is RadioConfig, isTrue);
      expect(config.arrayItems[3] is ToggleConfig, isTrue);
      expect(config.arrayItems[4] is SliderConfig, isTrue);

      expect(config.type, FieldType.array);
      expect(config.value, isEmpty);
    });
  });
}
