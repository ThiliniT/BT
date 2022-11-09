import ballerinax/salesforce;

import ballerina/http;
import ballerina/io;
import ballerina/log;

configurable string REFRESH_TOKEN = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

resource function post ada(@http:Payload json details) returns json|http:NotFound|error {

    string BASE_URL = "https://grkm-dev-ed.develop.my.salesforce.com";
    string REFRESH_URL = "https://grkm-dev-ed.develop.my.salesforce.com/services/oauth2/token";
    //string REFRESH_TOKEN = "5Aep861g78ZB7.52Bcbzp5RXx9Ly.Yg9Xpv26JgqdGdpdwYj6vPCIzChJ8QqLFxx7ZCBlLvUOMPVvbmrGXFDR7P";
    string CLIENT_ID = "3MVG9DREgiBqN9Wm6jYc9rfBbIbPDke2sYK7Ln9v2ape9omciczo_wKLa0MzTbUb0qIhwtFTI96Lo1TSjb.Nj";
    string CLIENT_SECRET = "23046CCAA74A3D745BC8A3A00622FD5987AF708CAFA757948A5132A30A0E3C31";

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
    salesforce:Client sfdcEp = check new(sfConfig);
    string email = check details.email;
    string sampleQuery1 = "SELECT Id FROM Contact WHERE Email="+ "'" +email+ "'";
    string sampleQuery2 = "SELECT Id FROM Lead WHERE Email="+ "'" +email+ "'";

    stream<record {}, error?> queryResults= check sfdcEp->query(sampleQuery1);

    check from var line in queryResults
        do {
            io:println(line);
            count1+=1;
            log:printInfo("*************FOUND Email in Salesforce********");      
        };
    if(count1==1)
    {
        return {"profile": { "email": email}};
    }
    else
    {
        log:printInfo("*************Email not found in Contact, Checking LEAD********");
        stream<record {}, error?> queryResults2= check sfdcEp->query(sampleQuery2);

        check from var line in queryResults2
            do {
                io:println(line);
                count2+=1;
            };
        if(count2>0)
        {
            return {"profile": { "email": email}};
        }
           
    }

    http:NotFound nf = { body: { msg: {"profile": "Not Found"}} };
    return nf;

    }
     
}
