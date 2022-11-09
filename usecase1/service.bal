import ttm04/greetingsapi;
import ballerina/http;

configurable string serviceUrl = ?;

configurable string clientSecret = ?;

configurable string clientId = ?;
# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns json|error {
        // Send a response back to the caller.

        greetingsapi:Client greetingapiEp = check new (clientConfig = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        }, serviceUrl = serviceUrl);
        return greetingapiEp->getGreeting(serviceUrl, "GET", name);
    }

    resource function post greeting(string name) returns json|error {
        // Send a response back to the caller.
        greetingsapi:Client greetingapiEp = check new (clientConfig = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        }, serviceUrl = serviceUrl);
        return greetingapiEp->getGreeting(serviceUrl, "POST", name);
    }
}