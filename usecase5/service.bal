import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/oracledb;
import ballerinax/mssql;

configurable string OracleDBURL = ?;
configurable string OraclsDB = ?;
configurable string OracleUsername = ?;
configurable string OraclePWD = ?;
configurable string OracleDBName = ?;
configurable int OraclePort = ?;

configurable string MSSQLDBURL = ?;
configurable string MSSQLDB = ?;
configurable string MSSQLUsername = ?;
configurable string MSSQLPWD = ?;
configurable string MSSQLDBName = ?;
configurable int MSSQLPort = ?;

oracledb:Client dbClientODB = check new (OracleDBURL, OracleUsername, OraclePWD, OracleDBName, OraclePort, options = {useXADatasource: true}
    );

mssql:Client dbClientMSDB = check new (MSSQLDBURL, MSSQLUsername, MSSQLPWD, MSSQLDBName, MSSQLPort,
                                connectionPool = {maxOpenConnections: 1},
                                options = {useXADatasource: true});

type Employee record {

    int EmployeeId;
    string FirstName;
    string LastName;
    string Email;
    string Phone;
    string Hiredate;
};

service / on new http:Listener(9090) {

    resource function get employees() returns error? {

        Employee[] empArr = [];

        stream<Employee, error?> resultStream = dbClientODB->query(`SELECT * FROM choreo.dbo.Employee`);

        check from Employee emp in resultStream
            do {
                io:println(`Customer Details: ${emp}`);
                empArr.push(emp);
            };

        io:println(empArr);
    }

    resource function put employees/[int id]/[int phoneno]() returns error? {

        transaction {

            sql:ExecutionResult sqlResult1 = check dbClientODB->execute(`UPDATE Employee SET phone = ${phoneno} WHERE EMPLOYEEID = ${id}`);

            sql:ExecutionResult sqlResult2 = check dbClientMSDB->execute(`UPDATE choreo.dbo.Employees SET phone = ${phoneno} WHERE EMPLOYEEID = ${id}`);

            check commit;
        }
        on fail error e {
            io:println(e.message());
            io:println("transaction failed");
        }

        check dbClientODB.close();
        check dbClientMSDB.close();

    }

}

