import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';
import 'package:snippet_app/features/library/domain/repositories/popular_book_repository.dart';

class PopularBooksParams {
  final String startDt;
  final String endDt;
  final String kdc;
  final String dtlKdc;
  final String age;
  final String gender;
  final String region;
  final String dtlRegion;
  final int pageNo;
  final int pageSize;

  const PopularBooksParams({
    this.startDt = '',
    this.endDt = '',
    this.kdc = '',
    this.dtlKdc = '',
    this.age = '',
    this.gender = '',
    this.region = '',
    this.dtlRegion = '',
    this.pageNo = 1,
    this.pageSize = 20,
  });
}

class FetchPopularBooksUseCase {
  final PopularBookRepository _repository;

  FetchPopularBooksUseCase(this._repository);

  Future<Result<List<PopularBookDto>>> call(PopularBooksParams params) {
    return _repository.getPopularBooks(
      startDt: params.startDt,
      endDt: params.endDt,
      kdc: params.kdc,
      dtlKdc: params.dtlKdc,
      age: params.age,
      gender: params.gender,
      region: params.region,
      dtlRegion: params.dtlRegion,
      pageNo: params.pageNo,
      pageSize: params.pageSize,
    );
  }
}
