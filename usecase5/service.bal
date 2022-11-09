import ballerina/http;
import ballerina/io;
import ballerinax/java.jdbc;
//import ballerinax/mysql;
import ballerina/sql;
import ballerinax/oracledb;

# A service representing a network-accessible API
# bound to port `9090`.
# 
# 

 jdbc:Client DB1 = check new (
    url= "jdbc:mysql://0.tcp.au.ngrok.io:14392/sys?useLegacyDatetimeCode=false&serverTimezone=UTC",
    user= "root",
    password = "Wso2ttm@91",
    options = {properties: {isXA : true}}
);

jdbc:Client DB2 = check new (
    url= "jdbc:mysql://0.tcp.au.ngrok.io:14392/poc?useLegacyDatetimeCode=false&serverTimezone=UTC",
    user= "root",
    password = "Wso2ttm@91",
    options = {properties: {isXA : true}}
);

 oracledb:Client dbClient = check new ("choreo-poc-oracle-db.cqdab9f9owoz.us-east-1.rds.amazonaws.com", "admin", "Choreo#1", 
                              "ORCL", 1521);

type Employee record {

        int EmployeeId;
        string FirstName;
        string LastName;
        string Email;
        string Phone;
        string Hiredate;
};


// The initialization expression of an `isolated` variable
// has to be an `isolated` expression, which itself will be
// an `isolated` root.
isolated string dbLog = "";
service / on new http:Listener(9090) {

resource function get employees() returns error|Employee[]? {

        Employee[] empArr = [];

       stream<Employee, sql:Error?> resultStream = dbClient->query(`SELECT * FROM EMPLOYEE`);

        check from Employee emp in resultStream
            do {
                io:println(`Customer Details: ${emp}`);
                empArr.push(emp);
            };

        io:println(empArr);
        return empArr;

    }

resource function put employees/[int id](int phoneno)  returns error|string? {

     
        var ret = DB1->execute(`CREATE TABLE EMPLOYEE
        (EMPLOYEEID INT AUTO_INCREMENT,
        FIRSTNAME VARCHAR(30),
        LASTNAME VARCHAR(30), 
        PHONE VARCHAR(30),
        HIREDATE DATE,
        SALARY INT,
        PRIMARY KEY (EMPLOYEEID)
        )`);
        
        handleUpdate(ret, "Create Employee table in DB1");

    
        transaction {
            error? updateResult = update();
            ret = check DB1->execute(`UPDATE Employee SET phone = ${phoneno} WHERE EMPLOYEEID = ${id}`);

            if (ret is sql:ExecutionResult) {
                int? count = ret.affectedRowCount;
                io:println("Inserted row count: ", count);

            } else {
                io:println("Insert to student table failed: ");
            }
                
            ret = check DB2->execute(`UPDATE Employee SET phone = ${phoneno}  WHERE EMPLOYEEID = ${id}`);
            handleUpdate(ret, "update value in DB2");
            
            check commit;
    }

            string temp ="";
            lock {
                temp = dbLog;
            }
            
            return temp;
}
   
}
transactional function update() returns error? {
    // Registers a commit handler to be invoked when `commit` is executed.
    transaction:onCommit(successLog);
    transaction:onRollback(logError);
}


isolated  function successLog('transaction:Info info) {
    io:println("Transaction success");
    lock{
        dbLog = "Transaction successful";
    }
   
  
}

isolated function logError(transaction:Info info, error? cause, boolean willRetry){
    io:println("Logged database update failure");
     lock{
        dbLog = "Logged database update failure";
    }
    
}

function handleUpdate(sql:ExecutionResult|error returned, string message) {
    if (returned is sql:ExecutionResult) {
        io:println(message, " status: ", returned.affectedRowCount);
    } else {
        io:println(message, " failed: ", <string>returned.message());
    }
}


    






