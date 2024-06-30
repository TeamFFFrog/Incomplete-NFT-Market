// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTmarket {
    IERC20 public erc20;
    IERC721 public erc721;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    struct Order {
        address seller;
        uint256 tokenID;
        uint256 price;
    }
    mapping (uint256 => Order) IDinOrder; // tokenid to order
    Order[] public orders;
    mapping (uint256 => uint256) IDofOrder;

    event Deal(address seller, address buyer, uint256 tokenID, uint256 price);
    event NewOrder(address seller, uint256 tokenID, uint256 price);
    event PriceChanged(address seller, uint256 tokenID, uint256 previousprice, uint256 newprice);
    event CancelOrder(address seller, uint256 tokenID);

    constructor(address _erc20, address _erc721){
        require(_erc20 != address(0), "zero address");
        require(_erc721 != address(0), "zero address");
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }

    function buy(uint256 _tokenID) external{
        address seller = IDinOrder[_tokenID].seller;
        address buyer = msg.sender;
        uint256 price = IDinOrder[_tokenID].price;

        require(erc20.transferFrom(buyer, seller, price), "transfer fail");
        erc721.safeTransferFrom(address(this), buyer, _tokenID);

        removeOrder(_tokenID);

        emit Deal(seller, buyer , _tokenID, price);
    }

    function cancel(uint256 _tokenID) external {
        address seller = IDinOrder[_tokenID].seller;
        require(msg.sender == seller, "not seller");

        erc721.safeTransferFrom(address(this), seller, _tokenID);

        removeOrder(_tokenID);

        emit CancelOrder(seller, _tokenID);
    }

    function change(uint256 _tokenID, uint256 _price) external {
        address seller = IDinOrder[_tokenID].seller;
        require(msg.sender == seller, "not seller");

        uint256 previousprice = IDinOrder[_tokenID].price;
        IDinOrder[_tokenID].price = _price;

        Order storage order = orders[IDofOrder[_tokenID]];
        order.price = _price;

        emit PriceChanged(seller, _tokenID, previousprice, _price);
    }

    function isListed(uint256 _tokenID) public view returns(bool) {
        return IDinOrder[_tokenID].seller != address(0);
    }

    function onERC721Received(address operator, address from, uint256 tokenID, bytes calldata data) external returns (bytes4) {
        uint256 price = toUint256(data, 0);
        require(price > 0, "price must be greater than 0");

        orders.push(Order(from, tokenID, price));
        IDinOrder[tokenID] = Order(from, tokenID, price);
        IDofOrder[tokenID] = orders.length - 1; 

        emit NewOrder(from, tokenID, price);

        return MAGIC_ON_ERC721_RECEIVED;
    }

    function removeOrder(uint256 _tokenID) internal  {
        uint256 index = IDofOrder[_tokenID];
        uint256 lastIndex = orders.length - 1;

        if (index != lastIndex){
            Order storage lastOrder = orders[lastIndex];
            orders[index] =  lastOrder;
            IDofOrder[lastOrder.tokenID] = index; 
        }
         
        orders.pop();
        delete IDinOrder[_tokenID];
        delete IDofOrder[index];
    }

    function toUint256(bytes memory _bytes, uint256 _start) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market:toUint256_overflow");
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function getOrderLength() external view returns(uint256){
        return orders.length;
    }

    function getAllNFTs() external view returns(Order[] memory) {
        return orders;
    }

    function getMyNFTs() external view returns(Order[] memory){
        Order[] memory myOrders = new Order[](orders.length);
        uint256 count = 0;
        for (uint256 i = 0; i < orders.length; i ++){
            if(orders[i].seller == msg.sender){
                myOrders[count] = orders[i];
                count ++;
            }
        }
        return myOrders;
    }
}


