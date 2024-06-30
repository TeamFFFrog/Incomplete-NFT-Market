// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTmarket.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor() ERC20("TestToken", "TT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract MyERC721 is ERC721 {
    uint256 private _currentTokenId = 0;

    constructor() ERC721("TestNFT", "TNFT") {}

    function mintTo(address recipient) public returns (uint256) {
        uint256 newTokenId = _currentTokenId;
        _currentTokenId++;
        _mint(recipient, newTokenId);
        return newTokenId;
    }
}

contract NFTmarketTest is Test {
    NFTmarket public market;
    MyERC20 public token;
    MyERC721 public nft;
    address public user;
    address public seller;

    function setUp() public {
        token = new MyERC20();
        nft = new MyERC721();
        market = new NFTmarket(address(token), address(nft));
        user = address(1);
        seller = address(2);

        token.transfer(user, 1000 * 10 ** token.decimals());
        token.transfer(seller, 1000 * 10 ** token.decimals());

        vm.startPrank(seller);
        nft.mintTo(seller);
        nft.approve(address(market), 0);
        bytes memory data = abi.encode(uint256(100 * 10 ** token.decimals()));
        market.onERC721Received(seller, seller, 0, data);
        vm.stopPrank();
    }

    function testBuy() public {
        vm.startPrank(user);
        token.approve(address(market), 100 * 10 ** token.decimals());
        market.buy(0);
        assertEq(nft.ownerOf(0), user);
        assertEq(token.balanceOf(seller), 100 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function testCancel() public {
        vm.startPrank(seller);
        market.cancel(0);
        assertEq(nft.ownerOf(0), seller);
        vm.stopPrank();
    }

    function testChange() public {
        vm.startPrank(seller);
        market.change(0, 200 * 10 ** token.decimals());
        (,,uint256 price) = market.orders(0);
        assertEq(price, 200 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function testIsListed() public {
        bool listed = market.isListed(0);
        assertTrue(listed);
    }

    function testGetOrderLength() public {
        uint256 length = market.getOrderLength();
        assertEq(length, 1);
    }

    function testGetAllNFTs() public {
        NFTmarket.Order[] memory orders = market.getAllNFTs();
        assertEq(orders.length, 1);
        assertEq(orders[0].tokenID, 0);
    }

    function testGetMyNFTs() public {
        vm.startPrank(seller);
        NFTmarket.Order[] memory myOrders = market.getMyNFTs();
        assertEq(myOrders.length, 1);
        assertEq(myOrders[0].tokenID, 0);
        vm.stopPrank();
    }
}
