import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/oracledb;
import ballerinax/mssql;


oracledb:Client dbClientODB = check new ("choreo-poc-oracle-db.cqdab9f9owoz.us-east-1.rds.amazonaws.com", "admin", "Choreo#1", "ORCL", 1521, options = {useXADatasource: true}
    );

mssql:Client dbClientMSDB = check new ("choreo-poc-sql-db.cqdab9f9owoz.us-east-1.rds.amazonaws.com", "admin", "Choreo#1", "master", 1433,
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

            sql:ExecutionResult sqlResult = check dbClientODB->execute(`UPDATE Employee SET phone = ${phoneno} WHERE EMPLOYEEID = ${id}`);

            sqlResult = check dbClientMSDB->execute(`UPDATE choreo.dbo.Employees SET phone = ${phoneno} WHERE EMPLOYEEID = ${id}`);

            check commit;
        }
        on fail error e {
            io:println(e.message());
            io:println("transaction failed");
        }

    }

}

