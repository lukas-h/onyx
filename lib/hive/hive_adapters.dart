import 'package:hive_ce/hive.dart';
import 'package:onyx/store/page_store.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<PageModel>(),
])
class HiveAdapters {}
