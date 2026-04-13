import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';

abstract class PopularBookRepository {
  Future<Result<List<PopularBookDto>>> getPopularBooks({
    String startDt,
    String endDt,
    String kdc,
    String dtlKdc,
    String age,
    String gender,
    String region,
    String dtlRegion,
    int pageNo,
    int pageSize,
  });
}
