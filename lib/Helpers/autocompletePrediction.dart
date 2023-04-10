class AutocompletePrediction {
  // [description]

  final String? description;

  final String? placeId;

  final StructuredFormating? structuredFormating;

  final String? reference;

  String? mainText = '';

  String? secondaryText = '';

  AutocompletePrediction(
      {this.description,
      this.placeId,
      this.reference,
      this.structuredFormating,
      this.mainText,
      this.secondaryText});

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      reference: json['reference'] as String?,
      structuredFormating: json['structure_formatting'] != null
          ? StructuredFormating.fromJson(json['structuredFormatting'])
          : null,
      mainText: json['structured_formatting']['main_text'] as String,
      secondaryText: json['structured_formatting']['secondary_text'] as String,
    );
  }
}

class StructuredFormating {
  final String? mainText;
  final String? secondaryText;

  StructuredFormating({this.mainText, this.secondaryText});

  factory StructuredFormating.fromJson(Map<String, dynamic> json) {
    return StructuredFormating(
        mainText: json["main_text"] as String?,
        secondaryText: json["secondary_text"] as String?);
  }
}
