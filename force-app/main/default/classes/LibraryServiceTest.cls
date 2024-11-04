@IsTest
public class LibraryServiceTest {

    @TestSetup
    static void createTestData() {
        // Crear libros de prueba
        Library_Book__c sampleBook1 = new Library_Book__c(Title__c = 'Sample Book One', Author__c = 'Author A', Available_Copies__c = 4, Total_Copies__c = 4);
        Library_Book__c sampleBook2 = new Library_Book__c(Title__c = 'Expert Book', Author__c = 'Author B', Available_Copies__c = 6, Total_Copies__c = 6);
        insert new List<Library_Book__c> { sampleBook1, sampleBook2 };
        
        // Crear contactos de prueba
        Contact testContact1 = new Contact(FirstName = 'Alice', LastName = 'Wonderland');
        Contact testContact2 = new Contact(FirstName = 'Bob', LastName = 'Builder');
        insert new List<Contact> { testContact1, testContact2 };
    }

    @IsTest
    static void validateBookSearchWithResults() {
        Test.startTest();
        
        List<Library_Book__c> foundBooksByTitle = LibraryService.searchBooks('Sample');
        System.assertEquals(1, foundBooksByTitle.size(), 'Should find one book matching the title "Sample".');
        System.assertEquals('Sample Book One', foundBooksByTitle[0].Title__c, 'Expected book title is "Sample Book One".');

        List<Library_Book__c> foundBooksByAuthor = LibraryService.searchBooks('Author B');
        System.assertEquals(1, foundBooksByAuthor.size(), 'Should find one book matching the author "Author B".');
        System.assertEquals('Expert Book', foundBooksByAuthor[0].Title__c, 'Expected book title is "Expert Book".');
        
        Test.stopTest();
    }

    @IsTest
    static void validateBookSearchNoResults() {
        Test.startTest();

        List<Library_Book__c> noMatchingBooks = LibraryService.searchBooks('Unknown Title');
        System.assertEquals(0, noMatchingBooks.size(), 'Should find no books matching the title "Unknown Title".');
        
        Test.stopTest();
    }

    @IsTest
    static void validateContactSearchWithResults() {
        Test.startTest();

        List<Contact> foundContactsByFirstName = LibraryService.searchContacts('Alice');
        System.assertEquals(1, foundContactsByFirstName.size(), 'Should find one contact matching the first name "Alice".');
        System.assertEquals('Wonderland', foundContactsByFirstName[0].LastName, 'Expected contact last name is "Wonderland".');

        List<Contact> foundContactsByLastName = LibraryService.searchContacts('Builder');
        System.assertEquals(1, foundContactsByLastName.size(), 'Should find one contact matching the last name "Builder".');
        System.assertEquals('Bob', foundContactsByLastName[0].FirstName, 'Expected contact first name is "Bob".');
        
        Test.stopTest();
    }

    @IsTest
    static void validateContactSearchNoResults() {
        Test.startTest();

        List<Contact> noMatchingContacts = LibraryService.searchContacts('Unknown Person');
        System.assertEquals(0, noMatchingContacts.size(), 'Should find no contacts matching the name "Unknown Person".');
        
        Test.stopTest();
    }

    @IsTest
    static void validateBookLoan() {
        // Recuperar el libro y el contacto para el test
        Library_Book__c testBook = [SELECT Id FROM Library_Book__c WHERE Title__c = 'Sample Book One' LIMIT 1];
        Contact borrower = [SELECT Id FROM Contact WHERE FirstName = 'Alice' LIMIT 1];

        Test.startTest();

        // Act: Prestar el libro
        Boolean loanResult = LibraryService.loanBook(testBook.Id, borrower.Id);
        
        // Assert: Verificar que el préstamo se haya realizado con éxito
        System.assert(loanResult, 'The loan operation should be successful.');

        // Verificar que se haya creado el registro del préstamo
        List<Library_Book_Loan__c> loanRecords = [SELECT Id FROM Library_Book_Loan__c WHERE Book__c = :testBook.Id AND Borrower__c = :borrower.Id];
        System.assertEquals(1, loanRecords.size(), 'There should be one loan record created.');

        Test.stopTest();
    }
}