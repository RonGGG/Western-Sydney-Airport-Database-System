# Western Sydney Airport Database Management System
## Introduction
This project is a Python-based database management system for the Western Sydney Airport. It is designed to handle and manage test events, facilitating the operations of technicians and test engineers. The system interacts with a PostgreSQL database, executing various operations like adding, updating, and retrieving test event data.

## Features
- Employee Login Validation: Verifies employee credentials for accessing the system.
- Test Event Management: Allows adding and updating test events in the database.
- Search Functionality: Enables searching for test events based on specific criteria.
- List Tests by Employee: Retrieves a list of all associated tests for a specific employee.

## Installation
To run this project, ensure you have Python and psycopg2 installed on your system. Clone the repository using the following command:
```
git clone https://github.com/RonGGG/Western-Sydney-Airport-Database-System.git
```
Navigate to the project directory and run the Python script.

## Usage
To use the system, execute the Python script. You can interact with the database through the provided functions:

- Validate employee login.  
  `checkEmpCredentials(username, password)`
- List all tests associated with an employee.  
  `findTestsByEmployee(username)`
- Find test events based on search criteria.  
  `findTestsByCriteria(searchString)`  
- Add a new test event.  
  `addTest(test_date, regno, status, technician, testengineer)`  
- Update an existing test event.  
  `updateTest(test_id, test_date, regno, status, technician, testengineer)`  
  

## Database Setup
Ensure that you have access to the PostgreSQL database and that your database credentials are correctly set in the script
