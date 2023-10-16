DROP TABLE IF EXISTS TestEvent;
DROP TABLE IF EXISTS TestStatus;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Aircraft;

CREATE TABLE Aircraft
(
	RegNo			VARCHAR(8)		PRIMARY KEY,
	Model			VARCHAR(12)		NOT NULL,
	AirlineOwner	VARCHAR(20)		NOT NULL
);

INSERT INTO Aircraft VALUES ('AC-ACAB','A321-200'  ,'Air Canada');
INSERT INTO Aircraft VALUES ('CA-CCAD','B747-400'  ,'Air China');
INSERT INTO Aircraft VALUES ('BA-EUPG','A319-100'  ,'British Airways');
INSERT INTO Aircraft VALUES ('JA-BNAS','A330-300'  ,'Japan Airlines');
INSERT INTO Aircraft VALUES ('KE-KALA','B777-200ER','Korean Air');
INSERT INTO Aircraft VALUES ('QF-APAC','A330-300'  ,'Qantas Airways');
INSERT INTO Aircraft VALUES ('SQ-CSEA','A380-800'  ,'Singapore Airlines');
INSERT INTO Aircraft VALUES ('TG-THAI','B777-300ER','Thai Airways');

CREATE TABLE Employee
(
	UserID			SERIAL			PRIMARY KEY,
	UserName		VARCHAR(20)		NOT NULL UNIQUE,
	Name			VARCHAR(100)	NOT NULL,
	Password		VARCHAR(20)		NOT NULL,
	Email			VARCHAR(50)     NOT NULL,
	Role			VARCHAR(20)		CHECK (Role in ('Technician','TestEngineer'))
);

INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('jkoi'		,'Jerry Koi'	,'000','jkoi@wsa.com.au'	,'Technician');		-- 1
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('jaddison'	,'Jo Addison'	,'111','jaddison@wsa.com.au','Technician');		-- 2
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('kagena'	,'Keiko Agena'	,'222','kagena@wsa.com.au'	,'Technician');		-- 3
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('sali'		,'Spiroz Ali'	,'333','sali@wsa.com.au'	,'Technician');		-- 4
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('sallen'	,'Steve Allen'	,'444','sallen@wsa.com.au'	,'Technician');		-- 5
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('famaro'	,'Fiona Amaro'	,'555','famaro@wsa.com.au'	,'Technician');		-- 6
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('abailey'	,'Alan Bailey'	,'666','abailey@wsa.com.au'	,'TestEngineer');	-- 7
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('cburr'	,'Carol Burr'	,'777','cburr@wsa.com.au'	,'TestEngineer');	-- 8
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('acarey'	,'Adam Carey'	,'888','acarey@wsa.com.au'	,'TestEngineer');	-- 9
INSERT INTO Employee (UserName,Name,Password,Email,Role) VALUES ('cchapman'	,'Colin Chapman','999','cchapman@wsa.com.au','TestEngineer');	-- 10

CREATE TABLE TestStatus
(
	TestStatusCode	VARCHAR(10)		PRIMARY KEY,
	TestStatusDesc	VARCHAR(30)		NOT NULL UNIQUE
);

INSERT INTO TestStatus (TestStatusCode,TestStatusDesc) VALUES ('TODO'  ,'Test to be performed');		-- 1
INSERT INTO TestStatus (TestStatusCode,TestStatusDesc) VALUES ('INPROG','Test in progress');			-- 2
INSERT INTO TestStatus (TestStatusCode,TestStatusDesc) VALUES ('PASS'  ,'Test completed and passed');	-- 3
INSERT INTO TestStatus (TestStatusCode,TestStatusDesc) VALUES ('FAIL'  ,'Test completed and failed');	-- 4

CREATE TABLE TestEvent
(
	TestID			SERIAL 			PRIMARY KEY,
	TestDate		DATE			NOT NULL,
	RegNo			VARCHAR(8)		NOT NULL,
	Status			VARCHAR(10)		NOT NULL REFERENCES TestStatus,
	Technician		INTEGER 		NOT NULL REFERENCES Employee,
	TestEngineer	INTEGER	 		NOT NULL REFERENCES Employee
);

INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('19/01/2022','BA-EUPG','INPROG',4,7);	-- 1
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('17/03/2022','KE-KALA','TODO'  ,2,7);	-- 2
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('26/02/2022','QF-APAC','FAIL'  ,5,9);	-- 3
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('02/03/2022','AC-ACAB','PASS'  ,3,7);	-- 4
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('02/03/2022','TG-THAI','INPROG',3,10);-- 5
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('10/03/2022','SQ-CSEA','INPROG',2,8);	-- 6
INSERT INTO TestEvent (TestDate,RegNo,Status,Technician,TestEngineer) VALUES ('25/01/2022','BA-EUPG','TODO'  ,2,8);	-- 7

/*Login Procedure*/
DROP FUNCTION IF EXISTS login_check(
	IN username_in VARCHAR, 
	IN password_in VARCHAR, 
	OUT userid_out INTEGER,
	OUT username_out VARCHAR,
	OUT name_out VARCHAR,
	OUT password_out VARCHAR,
	OUT email_out VARCHAR,
	OUT role_out VARCHAR);
CREATE OR REPLACE FUNCTION login_check (
	IN username_in VARCHAR, 
	IN password_in VARCHAR, 
	OUT userid_out INTEGER,
	OUT username_out VARCHAR,
	OUT name_out VARCHAR,
	OUT password_out VARCHAR,
	OUT email_out VARCHAR,
	OUT role_out VARCHAR) AS $$
BEGIN
SELECT userid,username,name,password,email,role 
INTO userid_out,username_out,name_out,password_out,email_out,role_out
FROM Employee 
WHERE username=username_in AND password=password_in;
END;$$ LANGUAGE plpgsql;

/*Add test Procedure*/
DROP FUNCTION IF EXISTS ADDTEST(TESTDATE DATE, 
								   REGNO_IN VARCHAR, 
								   EVENT_DESC VARCHAR, 
								   TECHNICIAN_UNAME VARCHAR, 
								   TESTENGINEER_UNAME VARCHAR);
CREATE OR REPLACE FUNCTION ADDTEST(TESTDATE DATE, 
								   REGNO_IN VARCHAR, 
								   EVENT_DESC VARCHAR, 
								   TECHNICIAN_UNAME VARCHAR, 
								   TESTENGINEER_UNAME VARCHAR)
RETURNS integer AS $$
DECLARE
	usid_technician INTEGER;
	usid_testengineer INTEGER;
	test_statuscode VARCHAR;
	reg_no VARCHAR;
BEGIN
	SELECT TE.regno, TS.teststatuscode, E_Tech.userid, E_Eng.userid
	INTO reg_no, test_statuscode, usid_technician, usid_testengineer
	FROM Employee E_Tech, Employee E_Eng, Teststatus TS, Testevent TE
	WHERE E_Tech.username=TECHNICIAN_UNAME
	AND E_Tech.role='Technician'
	AND E_Eng.username=TESTENGINEER_UNAME
	AND E_Eng.role='TestEngineer'
	AND TS.teststatusdesc=EVENT_DESC
	AND TE.regno=REGNO_IN;
	
	IF NOT FOUND THEN
	RETURN 0;
	END IF;

	INSERT INTO TESTEVENT VALUES (default,TESTDATE, reg_no, test_statuscode, usid_technician, usid_testengineer);
	RETURN 1;
END;
$$ LANGUAGE plpgSQL;

/*Update Tests*/
DROP FUNCTION IF EXISTS UPDATETEST(TESTID_IN INTEGER,
								   TESTDATE_IN DATE, 
								   REGNO_IN VARCHAR, 
								   EVENT_DESC VARCHAR, 
								   TECHNICIAN_UNAME VARCHAR, 
								   TESTENGINEER_UNAME VARCHAR);
CREATE OR REPLACE FUNCTION UPDATETEST(TESTID_IN INTEGER,
									  TESTDATE_IN DATE, 
									  REGNO_IN VARCHAR, 
									  EVENT_DESC VARCHAR, 
									  TECHNICIAN_UNAME VARCHAR, 
									  TESTENGINEER_UNAME VARCHAR)
RETURNS integer AS $$
DECLARE
	usid_technician INTEGER;
	usid_testengineer INTEGER;
	test_statuscode VARCHAR;
BEGIN
	SELECT TS.teststatuscode, E_Tech.userid, E_Eng.userid
	INTO test_statuscode,usid_technician,usid_testengineer
	FROM Employee E_Tech, Employee E_Eng, Teststatus TS, Testevent TE
	WHERE E_Tech.username=TECHNICIAN_UNAME
	AND E_Tech.role='Technician'
	AND E_Eng.username=TESTENGINEER_UNAME
	AND E_Eng.role='TestEngineer'
	AND TS.teststatusdesc=EVENT_DESC
	AND TE.regno=REGNO_IN;
	IF NOT FOUND THEN
	RETURN 0;
	END IF;
	
	UPDATE TESTEVENT
	SET testdate=TESTDATE_IN,
		regno=REGNO_IN,
		status=test_statuscode,
		technician=usid_technician,
		testengineer=usid_testengineer
	WHERE testid=TESTID_IN;
	RETURN 1;
END;
$$ LANGUAGE plpgSQL;
COMMIT;