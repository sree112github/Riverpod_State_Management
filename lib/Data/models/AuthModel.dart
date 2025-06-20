

class AuthModel{

  int userId;
  String userName;
  String userEmail;
  String bearerToken;

  AuthModel({required this.userId,required this.userName,required this.userEmail,required this.bearerToken});

  factory AuthModel.fromJson(Map<String,dynamic> json){

    return AuthModel(
        userId: int.tryParse(json['userId'])??0,
        userName: json['userName'],
        userEmail: json['userEmail'],
        bearerToken: json['bearerToken']
    );
  }

}