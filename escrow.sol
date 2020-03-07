pragma solidity ^0.5.16;

contract Escrow {
    
    mapping (address => uint256) public buyerBalance;
    //uint balance;
    
    mapping(address => address) public Deal;
    
    mapping(address => bool) public buyer;
    mapping(address => bool) public seller;
    
    mapping(address => bool) public _cbuyer;
    mapping(address => bool) public _cseller;
    
    mapping (address => uint256) public balanceOf;
    
    address payable escrow;
    uint private start;
    constructor() public {
        escrow = msg.sender;
        start = now; //now is an alias for block.timestamp, not really "now"
    }
    
    function startEscrowSigner(address _buyer, address _seller, uint256 _amount) public returns(bool){
        
        require(Deal[_buyer]!=_seller,"Pending");
        
        _amount=_amount*(10**18);
        buyerBalance[_buyer] += _amount;
        
        Deal[_buyer]=_seller;
        return true;
    }
    
    
   
    
    function releaseEscrowSigner(address payable _buyer, address payable _seller) public returns(bool){
        
        require(Deal[_buyer]==_seller,"Deal Not Exist");
        if (msg.sender == _buyer){
            buyer[_buyer] = true;
        } else if (msg.sender == _seller){
            seller[_seller] = true;
        }
        if (buyer[_buyer] && seller[_seller]){
            payBalance(_buyer,_seller);
        } 
        return true;
    }
    
    
    function () payable external{}
    
    function payBalance(address _buyer, address payable _seller) public payable{
        
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
    
    
    function deposit(address _buyer) public payable {
        if (msg.sender == _buyer) {
            buyerBalance[_buyer] += msg.value;
        }
    }
    
    function cancel(address payable _buyer, address _seller) public {
        
        require(Deal[_buyer]==_seller,"Deal Not Exist");
         
        if (msg.sender == _buyer){
            _cbuyer[_buyer] = true;
        } else if (msg.sender == _seller){
            _cseller[_seller] = true;
        }
        // if both buyer and seller would like to cancel, money is returned to buyer 
        if (_cbuyer[_buyer] && _cseller[_seller]){
            
            if (_buyer.send(buyerBalance[_buyer])) {
                buyerBalance[_buyer] = 0;
            }
        }
    }
    
    function collectUsdt() public{
        
    }
    
    function kill(address payable _buyer) public  {
        
        require(Deal[_buyer]!=address(0),"Address Doesnot Exist");
        if (msg.sender == escrow) {
            
            if (_buyer.send(buyerBalance[_buyer])) {
                buyerBalance[_buyer] = 0;
            }
        }
    }
}
