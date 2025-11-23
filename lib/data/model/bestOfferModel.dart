import 'package:erestroSingleVender/data/model/sliderModel.dart';

class BestOfferModel {
  String? id;
  String? type;
  String? typeId;
  String? branchId;
  String? image;
  String? dateAdded;
  String? bannerImage;
  List<Data>? data;

  BestOfferModel(
      {this.id,
      this.type,
      this.typeId,
      this.branchId,
      this.image,
      this.dateAdded,
      this.bannerImage,
      this.data});

  BestOfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    typeId = json['type_id'];
    branchId = json['branch_id'];
    image = json['image'];
    dateAdded = json['date_added'];
    bannerImage = json['banner_image'];
    data = json['data'] == null
        ? []
        : (json['data'] as List).map((e) => Data.fromJson(e ?? {})).toList();
  }
}

class States {
  bool? opened;

  States({this.opened});

  States.fromJson(Map<String, dynamic> json) {
    opened = json['opened'] ?? false;
  }
}
