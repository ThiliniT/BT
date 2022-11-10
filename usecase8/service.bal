import ballerina/http;
import ballerina/lang.runtime;
import ballerina/io;

configurable string serviceUrl1 = ?;
configurable string serviceUrl2 = ?;
service / on new http:Listener(9090) {

    resource function post greeting(@http:Payload json payload) returns json|http:Accepted|http:InternalServerError|error {

        final http:Client clientEp = check new (serviceUrl1);
        string resourcePath = "";

        http:InternalServerError intS = {body: "Internal server error"};
        json response = {};
        do {
            response = check clientEp->post(resourcePath, payload,
        headers = {
                "Content-Type": "application/json"
            },
        mediaType = "application/json");
        }
        on fail var varName {
            io:println(varName);
        }

        http:Accepted ac = {body: check response};
        future<json|error> fut = start longrun(payload);

        if (payload.name is error)
        {
            return intS;
        }
        return ac;
    }
}

function longrun(json payload) returns json|error {
    io:println("function called");
    runtime:sleep(20);
    final http:Client clientEp = check new (serviceUrl2);
    string resourcePath = "";
    json|http:ClientError response = clientEp->post(resourcePath, payload,
            headers = {
        "Content-Type": "application/json"
    },
            mediaType = "application/json");
    io:println("response returned");
    return check response;
}

