class MessageModel {
  final String phoneNumber;
  final String? text;
  final String? type;
  final String? audioUrl;  // Change from File to String for URL
  final String? imageUrl;   // Change from File to String for URL
  final double latitude;
  final double longitude;
  final String? status ;

  MessageModel( {
    required this.phoneNumber,
    this.text,
    this.type,
    this.audioUrl,
     this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'text': text,
     'type': type,
    'status': status,
    'audio_url': audioUrl,  // Store URL as string
    'image_url': imageUrl,  // Store URL as string
    'latitude': latitude,
    'longitude': longitude,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      phoneNumber: json['phone_number'],
      text: json['text'],
      type: json['type'],
      status: json['status'],
      audioUrl: json['audio_url'],  // Get URL as string
      imageUrl: json['image_url'],  // Get URL as string
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
