// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract DEX {

    event Bought(uint amount);
    //event Sold(uint amount);

// 1 wei can exchange 100 wei token
    uint public Rate=100;


    address public  ContractOwner;
 address public  USDTokenAddress;

    IERC20 public token;
IERC20 public USDToken;


    constructor(address TokenAddress,uint _rate,address _USDTokenAddress) { 
           token = IERC20(TokenAddress);
           ContractOwner=msg.sender;
           Rate=_rate;
           USDToken = IERC20(_USDTokenAddress);

    }


     modifier onlyOwner() {
        require(msg.sender == ContractOwner, "sender is not the owner");
        _;
    }


    function EtherToToken() payable public {
        uint UserSendEther = msg.value;
        uint UserGetToken=UserSendEther * Rate;
        uint dexBalance = token.balanceOf(address(this));
        require(UserSendEther > 0, "You need to send some ether");
        require(UserGetToken <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, UserGetToken);
        emit Bought(UserGetToken);
    }


    function TokenToToken(uint256 amount) public {
        require(amount > 0, "Your token is not enough.");
        uint UserGetToken=amount * Rate;

        uint256 allowance = USDToken.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");

        USDToken.transferFrom(msg.sender, address(this), amount);
        token.transfer(msg.sender, UserGetToken);
    
    }



        function GetAmountsOut(uint UserSendAmount)  view public returns (uint){
            return  UserSendAmount * Rate;
        }

        function SetRate(uint NewRate)    public onlyOwner {
             Rate= NewRate;
        }

       function TransferToken(address ToAddress,uint Amount)    public onlyOwner {
              token.transfer(ToAddress, Amount);
        }


       function TransferETH( address payable _receiver,uint256 _Amount) public onlyOwner  {
        (_receiver).transfer(_Amount);
       }


 

 
}
