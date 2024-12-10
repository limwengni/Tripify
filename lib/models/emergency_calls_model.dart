class EmergencyCallsModel {
  final String countryCode;
  final int police;
  final int fire;
  final int ambulances;

  // Constructor
  EmergencyCallsModel({
    required this.countryCode,
    required this.police,
    required this.fire,
    required this.ambulances,
  });

  // From Map
  factory EmergencyCallsModel.fromMap(Map<String, dynamic> map) {
    return EmergencyCallsModel(
      countryCode: map['country_code'] as String,
      police: map['police'] as int,
      fire: map['fire'] as int,
      ambulances: map['ambulances'] as int,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'country_code': countryCode,
      'police': police,
      'fire': fire,
      'ambulances': ambulances,
    };
  }
}
