import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get greeting() returns json|error {
        http:Client securedEP = check new("https://635f5e4f3e8f65f283b197bc.mockapi.io/hello/name",
            secureSocket = {
                cert : "/Users/wso2/Certs/mockapi-io.pem"
            }
        );

        json response = check securedEP->get("/");
        return response;
    }
}
