class OfflineCartModel {
  String? id;
  String? vId;
  String? pId;
  String? qty;
  String? addOnId;
  String? addOnQty;
  String? total;
  String? branchId;
  String? cid;

  OfflineCartModel(
      {this.id,
      this.vId,
      this.pId,
      this.qty,
      this.addOnId,
      this.addOnQty,
      this.total,
      this.branchId,
      this.cid});

  OfflineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    vId = json['VID'].toString();
    pId = json['PID'].toString();
    qty = json['QTY'].toString();
    addOnId = json['ADDONID'].toString();
    addOnQty = json['ADDONQTY'].toString();
    total = json['TOTAL'].toString();
    branchId = json['BRANCHID'].toString();
    cid = json['cid'].toString();
  }

  OfflineCartModel copyWith(
      {String? id,
      String? vId,
      String? pId,
      String? qty,
      String? addOnId,
      String? addOnQty,
      String? total,
      String? branchId,
      String? cid}) {
    return OfflineCartModel(
        id: this.id,
        vId: this.vId,
        pId: this.pId,
        qty: qty ?? this.qty,
        addOnId: this.addOnId,
        addOnQty: this.addOnQty,
        total: this.total,
        branchId: this.branchId,
        cid: this.cid);
  }
}
