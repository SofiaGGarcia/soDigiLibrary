public with sharing class LibraryService {
    @AuraEnabled(cacheable=true)
    public static List<Library_Book__c> searchBooks(String searchTerm) {

        String formattedSearchTerm = '%' + searchTerm + '%';
        List<Library_Book__c> books = [SELECT Id, Title__c, Author__c, Available_Copies__c
                                       FROM Library_Book__c
                                       WHERE Title__c LIKE :formattedSearchTerm OR Author__c LIKE :formattedSearchTerm
                                       LIMIT 10];
        return books;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        String formattedSearchTerm = '%' + searchTerm + '%';
        return [SELECT Id, FirstName, LastName 
                FROM Contact 
                WHERE FirstName LIKE :formattedSearchTerm OR LastName LIKE :formattedSearchTerm
                LIMIT 10];
    }

    @AuraEnabled
public static Boolean loanBook(Id bookId, Id borrowerId) {
    Library_Book_Loan__c loan = new Library_Book_Loan__c(
        Borrower__c = borrowerId,
        Book__c = bookId,
        Loan_Start_Date__c = Date.today()
    );
    insert loan;
    return true; 
}

}