import ballerina/http;
import ballerina/xslt;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post greeting/hello(@http:Payload xml param) returns xml|error? {
    xml xsl = check getXsl();
    xml target = check xslt:transform(param, xsl);
    return target;

    }
}


function getXsl() returns xml|error {
    return  check io:fileReadXml("./inputs/inputxsl.xml");
       
}