import ballerinax/salesforce;

import ballerina/http;
import ballerina/io;
import ballerina/log;

configurable string REFRESH_TOKEN = ?;

configurable string BASE_URL = ?;

configurable string REFRESH_URL = ?;

configurable string CLIENT_ID = ?;

configurable string CLIENT_SECRET = ?;

service / on new http:Listener(9090) {

    resource function post ada(@http:Payload json details) returns json|http:NotFound|error {

        int count1 = 0;
        int count2 = 0;

        salesforce:ConnectionConfig sfConfig = {
            baseUrl: BASE_URL,
            clientConfig: {
                clientId: CLIENT_ID,
                clientSecret: CLIENT_SECRET,
                refreshToken: REFRESH_TOKEN,
                refreshUrl: REFRESH_URL
            }
        };
        salesforce:Client sfdcEp = check new (sfConfig);
        string email = check details.email;
        string sampleQuery1 = "SELECT Id FROM Contact WHERE Email=" + "'" + email + "'";
        string sampleQuery2 = "SELECT Id FROM Lead WHERE Email=" + "'" + email + "'";

        stream<record {}, error?> queryResults = check sfdcEp->query(sampleQuery1);

        check from var line in queryResults
            do {
                io:println(line);
                count1 += 1;
                log:printInfo("*************FOUND Email in Salesforce********");
            };
        if (count1 == 1)
    {
            return {"profile": {"email": email}};
        }
    else
    {
            log:printInfo("*************Email not found in Contact, Checking LEAD********");
            stream<record {}, error?> queryResults2 = check sfdcEp->query(sampleQuery2);

            check from var line in queryResults2
                do {
                    io:println(line);
                    count2 += 1;
                };
            if (count2 > 0)
        {
                return {"profile": {"email": email}};
            }

        }

        http:NotFound nf = {body: {msg: {"profile": "Not Found"}}};
        return nf;

    }

}
