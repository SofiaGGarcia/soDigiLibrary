@IsTest
public class LoanManagementTest {
    @TestSetup
    static void initializeTestData() {
        
        Library_Book__c sampleBook1 = new Library_Book__c(Title__c = 'Sample Book One', Author__c = 'Author A', Available_Copies__c = 5, Total_Copies__c = 5);
        Library_Book__c sampleBook2 = new Library_Book__c(Title__c = 'Sample Book Two', Author__c = 'Author B', Available_Copies__c = 0, Total_Copies__c = 1);
        insert new List<Library_Book__c> { sampleBook1, sampleBook2 };

        Contact testBorrower = new Contact(FirstName = 'Alice', LastName = 'Wonderland');
        insert testBorrower;
    }

    @IsTest
    static void validateLoanInsertionWithAvailableCopies() {
        
        Library_Book__c book = [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Title__c = 'Sample Book One'];
        Contact borrower = [SELECT Id FROM Contact WHERE LastName = 'Wonderland'];

        Library_Book_Loan__c loanRecord = new Library_Book_Loan__c(
            Book__c = book.Id, 
            Borrower__c = borrower.Id, 
            Loan_Start_Date__c = Date.today(), 
            Loan_End_Date__c = Date.today().addDays(7)
        );

        Test.startTest();
        insert loanRecord;
        Test.stopTest();

        book = [SELECT Available_Copies__c FROM Library_Book__c WHERE Id = :book.Id];
        System.assertEquals(4, book.Available_Copies__c, 'The number of available copies should be decreased by 1 after loan insertion.');
    }

    @IsTest
    static void validateLoanInsertionWithNoAvailableCopies() {
        
        Library_Book__c book = [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Title__c = 'Sample Book Two'];
        Contact borrower = [SELECT Id FROM Contact WHERE LastName = 'Wonderland'];

        Library_Book_Loan__c loanRecord = new Library_Book_Loan__c(
            Book__c = book.Id, 
            Borrower__c = borrower.Id, 
            Loan_Start_Date__c = Date.today(), 
            Loan_End_Date__c = Date.today().addDays(7)
        );

        Test.startTest();
        try {
            insert loanRecord;
            System.assert(false, 'An exception should have been thrown when trying to loan a book with no available copies.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('No available copies of this book.'), 
                          'The expected error message should indicate no available copies.');
        }
        Test.stopTest();
    }

    @IsTest
    static void validateLoanDeletion() {
        
        Library_Book__c book = [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Title__c = 'Sample Book One'];
        Contact borrower = [SELECT Id FROM Contact WHERE LastName = 'Wonderland'];
       
        Library_Book_Loan__c loanRecord = new Library_Book_Loan__c(
            Book__c = book.Id, 
            Borrower__c = borrower.Id, 
            Loan_Start_Date__c = Date.today(), 
            Loan_End_Date__c = Date.today().addDays(7)
        );
        insert loanRecord;

        book = [SELECT Available_Copies__c FROM Library_Book__c WHERE Id = :book.Id];
        System.assertEquals(4, book.Available_Copies__c, 'Available copies should decrease by 1 after loan creation.');

        Test.startTest();
        delete loanRecord;
        Test.stopTest();

        book = [SELECT Available_Copies__c FROM Library_Book__c WHERE Id = :book.Id];
        System.assertEquals(5, book.Available_Copies__c, 'Available copies should increase by 1 after loan deletion.');
    }
}