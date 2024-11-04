trigger LoanManagement on Library_Book_Loan__c (before insert , before delete) {
   
    public class NoAvailableCopiesException extends Exception {}
    
    Map<Id, Library_Book__c> booksToModify = new Map<Id, Library_Book__c>();
    
    if (Trigger.isInsert) {
        for (Library_Book_Loan__c loan : Trigger.new) {
            Id bookId = loan.Book__c;

            if (bookId != null) {
                Library_Book__c book = [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Id = :bookId FOR UPDATE];

                if (book.Available_Copies__c <= 0) {
                   
                    loan.addError('No available copies of this book.');
                } else {
                    
                    book.Available_Copies__c -= 1;
                    booksToModify.put(book.Id, book);
                }
            }
        }
    }

    if (Trigger.isDelete) {
        for (Library_Book_Loan__c loan : Trigger.old) {
            Id bookId = loan.Book__c;

            if (bookId != null) {
                Library_Book__c book = [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Id = :bookId FOR UPDATE];
                                
                book.Available_Copies__c += 1;
                booksToModify.put(book.Id, book);
            }
        }
    }

    if (!booksToModify.isEmpty()) {
        update booksToModify.values();
    }
}