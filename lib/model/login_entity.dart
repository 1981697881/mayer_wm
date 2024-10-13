// To parse this JSON data, do
//
//     final loginEntity = loginEntityFromJson(jsonString);

import 'dart:convert';
import 'package:mayer_wm/server/api.dart';
import 'package:dio/dio.dart';
import 'package:mayer_wm/http/api_response.dart';
import 'package:mayer_wm/http/httpUtils.dart';
LoginEntity loginEntityFromJson(String str) => LoginEntity.fromJson(json.decode(str));

String loginEntityToJson(LoginEntity data) => json.encode(data.toJson());

class LoginEntity {
	static Future<String> login(Map<String, dynamic> map) async {
		try {
			API api = new API();
			final response = await HttpUtils.post(await api.LOGIN_URL(),params: map);
			/*final res = response as Map<String, dynamic>;
			var data = LoginEntity.fromJson(res);*/
			return jsonEncode(response);//ApiResponse.completed(data);
		} on DioError catch (e) {
			return e.error;//ApiResponse.error(e.error);
		}
	}
	LoginEntity({
		required this.message,
		required this.messageCode,
		required this.loginResultType,
		this.context,
		this.kdsvcSessionId,
		this.formId,
		this.redirectFormParam,
		this.formInputObject,
		this.errorStackTrace,
		required this.lcid,
		this.accessToken,
		this.kdAccessResult,
		required this.isSuccessByApi,
	});

	String message;
	String messageCode;
	int loginResultType;
	dynamic context;
	dynamic kdsvcSessionId;
	dynamic formId;
	dynamic redirectFormParam;
	dynamic formInputObject;
	dynamic errorStackTrace;
	int lcid;
	dynamic accessToken;
	dynamic kdAccessResult;
	bool isSuccessByApi;

	factory LoginEntity.fromJson(Map<String, dynamic> json) => LoginEntity(
		message: json["Message"],
		messageCode: json["MessageCode"],
		loginResultType: json["LoginResultType"],
		context: json["Context"],
		kdsvcSessionId: json["KDSVCSessionId"],
		formId: json["FormId"],
		redirectFormParam: json["RedirectFormParam"],
		formInputObject: json["FormInputObject"],
		errorStackTrace: json["ErrorStackTrace"],
		lcid: json["Lcid"],
		accessToken: json["AccessToken"],
		kdAccessResult: json["KdAccessResult"],
		isSuccessByApi: json["IsSuccessByAPI"],
	);

	Map<String, dynamic> toJson() => {
		"Message": message,
		"MessageCode": messageCode,
		"LoginResultType": loginResultType,
		"Context": context,
		"KDSVCSessionId": kdsvcSessionId,
		"FormId": formId,
		"RedirectFormParam": redirectFormParam,
		"FormInputObject": formInputObject,
		"ErrorStackTrace": errorStackTrace,
		"Lcid": lcid,
		"AccessToken": accessToken,
		"KdAccessResult": kdAccessResult,
		"IsSuccessByAPI": isSuccessByApi,
	};
}
