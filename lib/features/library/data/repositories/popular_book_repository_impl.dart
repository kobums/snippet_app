import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/datasources/popular_book_remote_datasource.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';
import 'package:snippet_app/features/library/domain/repositories/popular_book_repository.dart';

class PopularBookRepositoryImpl implements PopularBookRepository {
  final PopularBookRemoteDataSource _remote;

  PopularBookRepositoryImpl(this._remote);

  @override
  Future<Result<List<PopularBookDto>>> getPopularBooks({
    String startDt = '',
    String endDt = '',
    String kdc = '',
    String dtlKdc = '',
    String age = '',
    String gender = '',
    String region = '',
    String dtlRegion = '',
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final books = await _remote.getPopularBooks(
        startDt: startDt,
        endDt: endDt,
        kdc: kdc,
        dtlKdc: dtlKdc,
        age: age,
        gender: gender,
        region: region,
        dtlRegion: dtlRegion,
        pageNo: pageNo,
        pageSize: pageSize,
      );
      return Success(books);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }
}
