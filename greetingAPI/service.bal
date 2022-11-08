//greetingAPI
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string serviceUrl, string method, string name) returns json|error {
        http:Client clientEp = check new(serviceUrl);

        if (method == "GET") {
            string resourcePath = string `?name=`+name;
            json response = check clientEp->get(resourcePath);
            return response;
        } else if (method == "POST") {
            string resourcePath = "";
            json response = check clientEp->post(resourcePath,
            {
                "name" : name
            },
            headers = {
                "Content-Type": "application/json"
            },
            mediaType = "application/json");
            return response;
        }
    }
}
