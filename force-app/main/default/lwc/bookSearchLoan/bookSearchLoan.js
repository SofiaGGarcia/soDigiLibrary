import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/LibraryService.searchBooks';
import searchContacts from '@salesforce/apex/LibraryService.searchContacts';
import loanBook from '@salesforce/apex/LibraryService.loanBook';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookSearchLoan extends LightningElement {
    @track searchTerm = '';
    @track books = [];
    @track borrowerSearchTerm = ''; 
    @track contacts = []; 
    @track selectedBorrowerId = ''; 
    columns = [
        { label: 'Title', fieldName: 'Title__c' },
        { label: 'Author', fieldName: 'Author__c' },
        { label: 'Available Copies', fieldName: 'Available_Copies__c' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Request Loan',
                name: 'requestLoan',
                variant: 'brand'
            }
        }
    ];
    
    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleBorrowerSearchTermChange(event) {
        this.borrowerSearchTerm = event.target.value;
    }

    handleSearch() {
        searchBooks({ searchTerm: this.searchTerm })
            .then(result => {
                this.books = result;
                this.searchTerm = '';
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleBorrowerSearch() {
        searchContacts({ searchTerm: this.borrowerSearchTerm })
            .then(result => {
                this.contacts = result;
                this.contactOptions = result.map(contact => ({
                    label: `${contact.FirstName} ${contact.LastName}`,
                    value: contact.Id
                }));
                this.borrowerSearchTerm = '';

                if (this.contactOptions.length > 0) {
                    this.selectedBorrowerId = this.contactOptions[0].value;
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleBorrowerSelect(event) {
        this.selectedBorrowerId = event.detail.value;
        console.log('Selected Borrower ID:', this.selectedBorrowerId);
    }

    handleRowAction(event) {
        const bookId = event.detail.row.Id;
        
        if (!this.selectedBorrowerId) {
            this.showToast('Error', 'Please select a borrower before requesting a loan.', 'error');
            return;
        }

        loanBook({ bookId: bookId, borrowerId: this.selectedBorrowerId })
            .then(() => {
                this.showToast('Success', 'Loan registered successfully', 'success');
                this.handleSearch(); 
                this.selectedBorrowerId = '';
                this.books = [];
            })
            .catch(error => {
                console.log(error); 
    
                const errorMessage = error.body && error.body.pageErrors && error.body.pageErrors.length > 0 
                    ? error.body.pageErrors[0].message 
                    : 'An unknown error occurred';
    
                if (errorMessage.includes('No available copies of this book.')) {
                    this.showToast('Error', 'No copies available for this book. Please try another book.', 'error');
                } else {
                    this.showToast('Error', errorMessage, 'error');
                }
                this.selectedBorrowerId = '';
                this.books = [];
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}

