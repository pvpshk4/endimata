import 'package:retrofit/retrofit.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';
import 'package:dio/dio.dart';

part 'app_data_api_service.g.dart';

@RestApi()
abstract class AppDataApiService {
  factory AppDataApiService(Dio dio, {String baseUrl}) = _AppDataApiService;

  @GET("/human_photos")
  Future<List<String>> getHumanPhotos();

  @GET("/catalog_items")
  Future<List<PhotoModel>> getCatalogItems();

  @GET("/wardrobe_items")
  Future<List<PhotoModel>> getWardrobeItems();

  @POST("/upload_human_photo")
  Future<void> addHumanPhoto(
    @Part(name: "file") String fileBase64,
    @Part(name: "user_name") String userName,
  );

  @POST("/upload_clothing_item")
  Future<void> addClothingItem(
    @Part(name: "file") String fileBase64,
    @Part(name: "user_name") String userName,
    @Part(name: "category") String category,
    @Part(name: "subcategory") String subcategory,
    @Part(name: "sub_subcategory") String subSubcategory,
  );

  @POST("/clear_data")
  Future<void> clearData();

  @DELETE("/delete_photo")
  Future<void> deletePhoto(@Query("id") String id, @Query("type") String type);
}
