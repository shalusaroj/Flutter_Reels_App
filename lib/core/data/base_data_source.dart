import 'package:reels_assignment/core/data/abstract_data_client.dart';

abstract class BaseDataSource<TClient extends AbstractDataClient> {
  const BaseDataSource(this.client);

  final TClient client;
}
