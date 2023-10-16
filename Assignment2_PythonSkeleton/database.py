#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################
userDetails = {}

'''
Connect to the database using the connection string
'''
def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "y22s1c9120_unikey"
    passwd = ""
    myHost = "soit-db-pro-2.ucc.usyd.edu.au"

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)
    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

'''
Validate employee login based on username and password
'''
def checkEmpCredentials(username, password):
    conn = openConnection()
    curs = conn.cursor()

    # curs.execute("CALL login_check(%s,%s);",(username,password))
    curs.callproc('login_check',[username,password])
    result = curs.fetchone()
    # print(result)
    

    # check whether the userid is null
    if result[0] == None:
        return None
    global userDetails
    userDetails = {
            'userid': result[0],
            'username': result[1],
            'name': result[2],
            'password': result[3],
            'email': result[4],
            'role': result[5],
        }
    # print(userDetails)
    curs.close()
    conn.close()
    return result


'''
List all the associated tests in the database for an employee
'''
def findTestsByEmployee(username):
    conn = openConnection()
    curs = conn.cursor()

    list_events=None
    if not username:
        print('Not username')
        if userDetails:
            username = userDetails['username']
            curs.execute("select TE.testid, TE.testdate, TE.regno, TS.teststatusdesc, E1.username as Technician, E2.username as TestEngineer \
                    from Employee E1, Employee E2, Testevent TE, Teststatus TS \
                    where TE.status=TS.teststatuscode \
                    and TE.technician=E1.userid \
                    and TE.testengineer=E2.userid \
                    and (E1.username = '{0}' \
                    or E2.username = '{0}')\
                    order by TE.testdate asc;".format(username))
            list_events = curs.fetchall()
        else:
            return None
    else:
        curs.execute("select TE.testid, TE.testdate, TE.regno, TS.teststatusdesc, E1.name as Technician, E2.name as TestEngineer \
                    from Employee E1, Employee E2, Testevent TE, Teststatus TS \
                    where TE.status=TS.teststatuscode \
                    and TE.technician=E1.userid \
                    and TE.testengineer=E2.userid \
                    and (E1.username = '{0}' \
                    or E2.username = '{0}')\
                    order by TE.testdate asc;".format(username))
        list_events = curs.fetchall()

    if len(list_events) == 0:
        return None
    
    return_list = []
    for i,event in enumerate(list_events):
        return_list.append({
            "test_id":str(event[0]),
            "test_date":event[1], 
            "regno":event[2], 
            "status":event[3], 
            "technician":event[4], 
            "testengineer":event[5]
        })
    # print(return_list)
    curs.close()
    conn.close()
    return return_list


'''
Find a list of test events based on the searchString provided as parameter
See assignment description for search specification
'''
def findTestsByCriteria(searchString):
    conn = openConnection()
    curs = conn.cursor()

    list_events = None
    if searchString == " ":
        curs.execute("select TE.testid, TE.testdate, TE.regno, TS.teststatusdesc, E1.name as Technician, E2.name as TestEngineer \
                from Employee E1, Employee E2, Testevent TE, Teststatus TS \
                where TE.status=TS.teststatuscode \
                and TE.technician=E1.userid \
                and TE.testengineer=E2.userid \
                and (E1.username = '{0}' \
                or E2.username = '{0}')\
                order by TE.testdate asc;".format(userDetails['username']))
        list_events = curs.fetchall()
    else:
        curs.execute("select TE.testid, TE.testdate, TE.regno, TS.teststatusdesc, E1.name as Technician, E2.name as TestEngineer \
                    from Employee E1, Employee E2, Testevent TE, Teststatus TS \
                    where TE.status=TS.teststatuscode \
                    and TE.technician=E1.userid \
                    and TE.testengineer=E2.userid \
                    and (LOWER(TE.regno) like LOWER('%{0}%' ) \
                    or LOWER(TS.teststatusdesc) like LOWER('%{0}%') \
                    or LOWER(E1.name) like LOWER('%{0}%') \
                    or LOWER(E2.name) like LOWER('%{0}%')) \
                    order by TE.testdate asc;".format(searchString))

        list_events = curs.fetchall()

    if len(list_events) == 0:
        return None
    
    return_list = []
    for i,event in enumerate(list_events):
        return_list.append({
            "test_id":event[0],
            "test_date":event[1], 
            "regno":event[2], 
            "status":event[3], 
            "technician":event[4], 
            "testengineer":event[5]
        })
    curs.close()
    conn.close()
    return return_list


'''
Add a new test event
'''
def addTest(test_date, regno, status, technician, testengineer):
    # Create new conenction and cursor towards the connection
    conn = openConnection()
    curs = conn.cursor()

    curs.execute("SELECT ADDTEST ('{0}','{1}','{2}','{3}','{4}');".format(test_date, regno, status, technician, testengineer))

    result = curs.fetchone()
    # print(result)
    conn.commit()

    curs.close()
    conn.close()
    if result[0] != 1:
        return False
    return True


'''
Update an existing test event
'''
def updateTest(test_id, test_date, regno, status, technician, testengineer):
    # Create new conenction and cursor towards the connection
    conn = openConnection()
    curs = conn.cursor()

    curs.execute("SELECT UPDATETEST ({0},'{1}','{2}','{3}','{4}','{5}');".format(test_id,test_date, regno, status, technician, testengineer))

    result = curs.fetchone()
    print(result)
    conn.commit()

    curs.close()
    conn.close()
    if result[0] != 1:
        return False
    return True