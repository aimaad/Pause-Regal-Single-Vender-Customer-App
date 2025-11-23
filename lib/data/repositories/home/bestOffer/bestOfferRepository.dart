import 'package:erestroSingleVender/data/model/bestOfferModel.dart';
import 'package:erestroSingleVender/data/repositories/home/bestOffer/bestOfferRemoteDataSource.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';

class BestOfferRepository {
  static final BestOfferRepository _bestOfferRepository =
      BestOfferRepository._internal();
  late BestOfferRemoteDataSource _bestOfferRemoteDataSource;

  factory BestOfferRepository() {
    _bestOfferRepository._bestOfferRemoteDataSource =
        BestOfferRemoteDataSource();
    return _bestOfferRepository;
  }

  BestOfferRepository._internal();

  Future<List<BestOfferModel>> getBestOffer(String? branchId) async {
    try {
      List<BestOfferModel> result =
          await _bestOfferRemoteDataSource.getBestOffer(branchId);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
