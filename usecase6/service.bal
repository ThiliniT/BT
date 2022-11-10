import ballerina/http;
import ballerina/io;
import ballerina/regex;
import ballerina/lang.'array as arr;
import ballerina/lang.'string as str;
import ballerina/log;

configurable string serviceUrl = ?;

final http:Client clientEp = check new (serviceUrl);

//comment

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post greeting(@http:Payload json payload, http:Headers headers) returns json|error {
        string resourcePath = "";
        string stringResult = check headers.getHeader("X-JWT-Assertion");
        string[] temp = regex:split(stringResult, "\\.");
        string base64EncodedBody = temp[1];

        //io:println(base64EncodedBody);
        byte[] decoded = check arr:fromBase64(base64EncodedBody);
        string decodedString = check str:fromBytes(decoded);
        //io:println(decodedString);
        json decodedPayload = check decodedString.fromJsonString();
        io:println(decodedPayload.sub);
        io:println(payload);

        log:printInfo(decodedPayload.toJsonString());
        json response = check clientEp->post(resourcePath, payload,
        headers = {
            "Content-Type": "application/json",
            "JWT-Header": base64EncodedBody
        },
        mediaType = "application/json");
        log:printInfo(response.toJsonString());
        return decodedPayload.sub;
    }
}
