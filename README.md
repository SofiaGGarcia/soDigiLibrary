# Library Management System

## Project Overview

The **Library Management System** project is designed to manage a corporate digital library, allowing employees to search for books, request loans, and handle book inventory. The solution includes a set of custom objects, a Lightning Web Component for user interaction, Apex classes for business logic, and triggers to maintain inventory integrity.

## Requirements

### 1. Book Inventory Management

- **Custom Object:** `Library_Book__c`
  - **Fields:**
    - `Title__c` (Text): The title of the book.
    - `Author__c` (Text): The author of the book.
    - `Available_Copies__c` (Number): The number of copies available for loan.
    - `Total_Copies__c` (Number): The total number of copies of the book.

### 2. Loan Record Registration

- **Custom Object:** `Library_Book_Loan__c`
  - **Fields:**
    - `Borrower__c` (Lookup to Contact): The person borrowing the book.
    - `Book__c` (Lookup to Library_Book\_\_c): The book being borrowed.
    - `Loan_Start_Date__c` (Date): Start date of the loan.
    - `Loan_End_Date__c` (Date): End date of the loan.

### 3. Loan Management Trigger

- **Trigger**: `LoanManagement` on `Library_Book_Loan__c`
  - Validates that a loan can only be registered if there are available copies (`Available_Copies__c > 0`).
  - Decreases `Available_Copies__c` by one when a loan is registered.
  - Increases `Available_Copies__c` by one when a loan is deleted.

### 4. Exception Handling

- **Custom Exception:** `NoAvailableCopiesException`
  - Handles cases where a user attempts to borrow a book without any available copies.
  - Implemented in the `LoanManagement` trigger.

### 5. User Interface

- **Lightning Web Component (LWC):** `bookSearchLoan`

  - Allows users to search for books by title or author using SOSL.
  - Displays book details, including the number of available copies.
  - Enables users to request a loan for a selected book.

- **Custom Application:** `Library_Management`

  - Provides an accessible interface in the App Launcher with tabs to access book records, loan records, and the search/loan interface.

- **Tabs:**

  - `Library_Book__c`: Tab for managing book records.
  - `Library_Book_Loan__c`: Tab for managing loan records.
  - `Library_Book_Search_Page`: Tab to access the `bookSearchLoan` LWC.

- **Flexipage:** `Library_Book_Search_Page`
  - Custom Lightning Page for the search and loan functionality, using the `bookSearchLoan` component.

### 6. Apex Classes

- **LibraryService**:
  - `searchBooks(String searchTerm)`: Searches for books by title or author using SOSL.
  - `loanBook(Id bookId, Id borrowerId)`: Handles book loan registration, with custom exception handling for unavailable copies.

### 7. SOQL Queries

- Optimized SOQL queries implemented within the `LibraryService` class and `LoanManagement` trigger for efficient data retrieval.

### 8. Testing

- **Unit Tests**:
  - `LibraryServiceTest` and `LoanManagementTest` provide complete unit test coverage (100%).

## Project Structure

The project files are structured as follows:

- **Custom Objects:** Defined under `force-app/main/default/objects/Library_Book__c` and `force-app/main/default/objects/Library_Book_Loan__c`.
- **Triggers:** Located in `force-app/main/default/triggers/LoanManagement.trigger`.
- **Apex Classes:** Located in `force-app/main/default/classes/LibraryService.cls` and test classes under `force-app/main/default/classes`.
- **Lightning Web Component:** `bookSearchLoan` in `force-app/main/default/lwc/bookSearchLoan`.
- **Layouts:** Defined under `force-app/main/default/layouts`.
- **Tabs and Flexipages:** Custom tabs and Flexipages located in `force-app/main/default/tabs` and `force-app/main/default/flexipages`.
- **Custom Application:** `Library_Management.app` located in `force-app/main/default/applications`.
