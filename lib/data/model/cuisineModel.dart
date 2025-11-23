class CuisineModel {
  String? id;
  String? name;
  String? parentId;
  String? branchId;
  String? slug;
  String? image;
  String? rowOrder;
  String? status;
  String? clicks;

  String? text;
  StateModel? state;
  String? icon;
  int? level;
  int? total;

  CuisineModel(
      {this.id,
      this.name,
      this.parentId,
      this.branchId,
      this.slug,
      this.image,
      this.rowOrder,
      this.status,
      this.clicks,
      this.text,
      this.state,
      this.icon,
      this.level,
      this.total});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentId = json['parent_id'];
    branchId = json['branch_id'];
    slug = json['slug'];
    image = json['image'];
    rowOrder = json['row_order'];
    status = json['status'];
    clicks = json['clicks'];

    text = json['text'];
    state = json['state'] != null ? StateModel.fromJson(json['state']) : null;
    icon = json['icon'];
    level = json['level'];
    total = json['total'];
  }
}

class StateModel {
  bool? opened;

  StateModel({this.opened});

  StateModel.fromJson(Map<String, dynamic> json) {
    opened = json['opened'];
  }
}
