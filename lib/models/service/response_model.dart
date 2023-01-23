import 'dart:convert';

class CustomResponseModel {
  final dynamic error;
  final dynamic data;
  final dynamic message;
  CustomResponseModel({
     this.error,
     this.data,
     this.message,
  });


  CustomResponseModel copyWith({
    dynamic? error,
    dynamic? data,
    dynamic? message,
  }) {
    return CustomResponseModel(
      error: error ?? this.error,
      data: data ?? this.data,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'error': error ?? "",
      'data': data ?? "",
      'message': message ?? "",
    };
  }

  factory CustomResponseModel.fromMap(Map<String, dynamic> map) {
    return CustomResponseModel(
      error: map['error'] ?? null,
      data: map['data'] ?? null,
      message: map['message'] ?? null,
    );
  }



  @override
  String toString() => 'ResponseModel(error: $error, data: $data, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CustomResponseModel &&
      other.error == error &&
      other.data == data &&
      other.message == message;
  }

  @override
  int get hashCode => error.hashCode ^ data.hashCode ^ message.hashCode;
}
