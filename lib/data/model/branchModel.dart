class BranchModel {
  String? id;
  String? branchName;
  String? description;
  String? address;
  String? cityId;
  String? latitude;
  String? longitude;
  String? email;
  String? contact;
  String? image;
  String? status;
  String? selfPickup;
  String? deliverOrder;
  String? defaultBranch;
  String? dateAdded;
  String? borderingCityIds;
  String? maxDeliverableDistance;
  String? name;
  String? deliveryChargeMethod;
  String? fixedCharge;
  String? perKmCharge;
  String? rangeWiseCharges;
  String? timeToTravel;
  String? geolocationType;
  String? radius;
  String? boundaryPoints;
  String? branchId;
  String? dateCreated;
  List<BranchWorkingTime>? branchWorkingTime;
  String? isBranchOpen;

  BranchModel(
      {this.id,
      this.branchName,
      this.description,
      this.address,
      this.cityId,
      this.latitude,
      this.longitude,
      this.email,
      this.contact,
      this.image,
      this.status,
      this.selfPickup,
      this.deliverOrder,
      this.defaultBranch,
      this.dateAdded,
      this.borderingCityIds,
      this.maxDeliverableDistance,
      this.name,
      this.deliveryChargeMethod,
      this.fixedCharge,
      this.perKmCharge,
      this.rangeWiseCharges,
      this.timeToTravel,
      this.geolocationType,
      this.radius,
      this.boundaryPoints,
      this.branchId,
      this.dateCreated,
      this.branchWorkingTime,
      this.isBranchOpen});

  BranchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchName = json['branch_name'];
    description = json['description'];
    address = json['address'];
    cityId = json['city_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    email = json['email'];
    contact = json['contact'];
    image = json['image'];
    status = json['status'];
    selfPickup = json['self_pickup'];
    deliverOrder = json['deliver_orders'];
    defaultBranch = json['default_branch'];
    dateAdded = json['date_added'];
    borderingCityIds = json['bordering_city_ids'];
    maxDeliverableDistance = json['max_deliverable_distance'];
    name = json['name'];
    deliveryChargeMethod = json['delivery_charge_method'];
    fixedCharge = json['fixed_charge'];
    perKmCharge = json['per_km_charge'];
    rangeWiseCharges = json['range_wise_charges'];
    timeToTravel = json['time_to_travel'];
    geolocationType = json['geolocation_type'];
    radius = json['radius'];
    boundaryPoints = json['boundary_points'];
    branchId = json['branch_id'];
    dateCreated = json['date_created'];
    if (json['branch_working_time'] != null) {
      branchWorkingTime = <BranchWorkingTime>[];
      json['branch_working_time'].forEach((v) {
        branchWorkingTime!.add(BranchWorkingTime.fromJson(v));
      });
    }
    isBranchOpen = json['is_branch_open'];
  }
}

class BranchWorkingTime {
  String? id;
  String? branchId;
  String? day;
  String? openingTime;
  String? closingTime;
  String? isOpen;
  String? dateCreated;

  BranchWorkingTime(
      {this.id,
      this.branchId,
      this.day,
      this.openingTime,
      this.closingTime,
      this.isOpen,
      this.dateCreated});

  BranchWorkingTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchId = json['branch_id'];
    day = json['day'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    isOpen = json['is_open'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['branch_id'] = this.branchId;
    data['day'] = this.day;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['is_open'] = this.isOpen;
    data['date_created'] = this.dateCreated;
    return data;
  }
}
