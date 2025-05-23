import 'package:onyx/service/origin_service.dart';

class LabelStore {
  List<OriginService> originServices = [];
  List<String> _labels = [];
  List<String> get labels => _labels;

  Future<void> init() async {
    for (final service in originServices) {
      _labels = await service.getLabels();
    }
  }

  Future<void> addLabel(String label) async {
    for (final service in originServices) {
      await service.createLabel(label);
    }
    _labels = await originServices[0].getLabels();
  }

  Future<void> removeLabel(String label) async {
    for (final service in originServices) {
      await service.deleteLabel(label);
    }
    _labels = await originServices[0].getLabels();
  }
}
