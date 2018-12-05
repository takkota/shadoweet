
class DialogFlowResponse {
  String responseText;
  String sessionId;
  bool expectResponse;
  bool consecutive;
  String saveDataKey;
  String saveDataValue;

  DialogFlowResponse({this.responseText, this.sessionId, this.consecutive, this.expectResponse, this.saveDataKey, this.saveDataValue});

// serverから取得したデータのParse用
  factory DialogFlowResponse.fromJson(Map<String, dynamic> json) {
    return DialogFlowResponse(
        responseText: json['response_text'],
        sessionId: json['session_id'],
        consecutive: json['consecutive'],
        expectResponse: json['expect_response'],
        saveDataKey: json['save_data_key'],
        saveDataValue: json['save_data_value']
    );
  }
}
