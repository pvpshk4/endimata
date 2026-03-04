import 'package:endimata/features/home/domain/entities/home_content_entity.dart';

abstract class HomeRepository {
  Future<HomeContentEntity> getHomeContent();
}
