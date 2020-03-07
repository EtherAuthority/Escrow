pragma solidity ^0.4.11;contract Escrow {
    
    mapping (address => uint256) public buyerBalance;
    //uint balance;
    
    mapping(address => address) public Deal;
    
    mapping(address => bool) public buyer;
    mapping(address => bool) public seller;
    
    mapping(address => bool) public _cbuyer;
    mapping(address => bool) public _cseller;
    
    address private escrow;
    uint private start;
    constructor() public {
        escrow = msg.sender;
        start = now; //now is an alias for block.timestamp, not really "now"
    }
    
    function startTrade(address _buyer, address _seller) public{
        
        require(Deal[_buyer]!=_seller,"Pending");
        Deal[_buyer]=_seller;
    }
   
    
    function accept(address _buyer, address _seller) public {
        
        require(Deal[_buyer]==_seller,"Deal Not Exist");
        if (msg.sender == _buyer){
            buyer[_buyer] = true;
        } else if (msg.sender == _seller){
            seller[_seller] = true;
        }
        if (buyer[_buyer] && seller[_seller]){
            payBalance(_buyer,_seller);
        } else if (buyer[_buyer] && !seller[_seller] && now > start + 30 days) {
            // Freeze 30 days before release to buyer. The customer has to remember to call this method after freeze period.
            selfdestruct(_buyer);
        }
    }
    
    function payBalance(address _buyer, address _seller) private {
        
        require(Deal[_buyer]==_seller,"Not Possible");
        // we are sending ourselves (contract creator) a fee
        escrow.transfer(address(this).balance / 100);
        // send seller the balance
        if (_seller.send(address(this).balance)) {
            buyerBalance[_buyer] = 0;
        } else {
            revert();
        }
    }
    
    // function deposit(address _buyer) public payable {
        
    //     require(Deal[_buyer]!=address(0),"Address Doesnot Exist");
    //     if (msg.sender == _buyer) {
    //         buyerBalance[_buyer] += msg.value;
    //     }
    // }
    
    function deposit(address _buyer) public payable {
        if (msg.sender == _buyer) {
            buyerBalance[_buyer] += msg.value;
        }
    }
    
    function cancel(address _buyer, address _seller) public {
        
        require(Deal[_buyer]==_seller,"Deal Not Exist");
         
        if (msg.sender == _buyer){
            _cbuyer[_buyer] = true;
        } else if (msg.sender == _seller){
            _cseller[_seller] = true;
        }
        // if both buyer and seller would like to cancel, money is returned to buyer 
        if (_cbuyer[_buyer] && _cseller[_seller]){
            selfdestruct(_buyer);
        }
    }
    
    function kill(address _buyer) public  {
        
        require(Deal[_buyer]!=address(0),"Address Doesnot Exist");
        if (msg.sender == escrow) {
            selfdestruct(_buyer);
        }
    }
}
