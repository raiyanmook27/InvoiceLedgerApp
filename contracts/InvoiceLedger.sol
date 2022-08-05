//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

/** @title A contract to create and retrieve invoice ledgers
    @notice check for payment status
*/
contract InvoiceLedger {
    /** 
        @notice check for payment status
    */
    enum Status {
        PAID,
        NOT_PAID
    }

    //
    /** 
        @notice create a struct for the invoice
    */
    struct Invoice {
        uint id;
        uint buyerPAN;
        uint sellerPAN;
        uint amount;
        string date;
        //check if paid
        Status isPaid;
    }

    // an array of invoices
    Invoice[] private ledger;

    //track buyers invoices;
    mapping(uint => Invoice) private buyersInvoice;

    //error
    error Invoice_NotFound();

    //modifiers
    modifier checkLedgerEmpty() {
        if (ledger.length == 0) revert Invoice_NotFound();
        _;
    }

    //events
    event ledgerCreated(
        uint id,
        uint buyerPAN,
        uint sellerPAN,
        uint amount,
        string date
    );
    event getInvoicesEvent(Invoice[] invoices);
    event paymentStatusChanged(uint _buyerPAN, Status _IsPaid);

    /** 
        @notice create a ledger 
        @param _buyerPAN, _sellerPAN,_amount,_date
    */
    function createLedger(
        uint _buyerPAN,
        uint _sellerPAN,
        uint _amount,
        string memory _date
    ) external {
        Status _Ispaid = Status.NOT_PAID;
        uint id = uint256(
            keccak256(
                abi.encodePacked(_buyerPAN, _sellerPAN, _amount, _date, _Ispaid)
            )
        );
        Invoice memory invoice = Invoice(
            id,
            _buyerPAN,
            _sellerPAN,
            _amount,
            _date,
            _Ispaid
        );

        ledger.push(invoice);
        emit ledgerCreated(id, _buyerPAN, _sellerPAN, _amount, _date);
    }

    /** 
        @notice create a ledger 
        @param _buyerPAN, _Status of payment
    */
    function paymentStatus(
        uint _id,
        uint _buyerPAN,
        Status _Ispaid
    ) external checkLedgerEmpty {
        uint len = ledger.length;
        for (uint i = 0; i < len; i++) {
            if (ledger[i].id == _id && ledger[i].buyerPAN == _buyerPAN) {
                ledger[i].isPaid = _Ispaid;
            }
        }
        emit paymentStatusChanged(_buyerPAN, _Ispaid);
    }

    /** 
        @notice create a ledger 
        @param _buyerPAN, _sellerPAN,_amount,_date
        @return a list of  buyers previous invoices.
    */
    function getInvoices(uint _buyerPAN)
        external
        checkLedgerEmpty
        returns (Invoice[] memory)
    {
        /**
            @notice if ledger is empty revert
        */
        uint len = ledger.length;
        Invoice[] memory prevInvoices = new Invoice[](len);
        for (uint i = 0; i < len; ++i) {
            if (ledger[i].buyerPAN == _buyerPAN) {
                prevInvoices[i] = ledger[i];
            }
        }
        emit getInvoicesEvent(prevInvoices);
        return prevInvoices;
    }
}
