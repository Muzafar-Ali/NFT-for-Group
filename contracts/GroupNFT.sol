//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GroupNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    

    string BaseTokenURI;
    uint price;
    uint maxLimit;
    uint maxSupplyCap;
    uint launched;
    uint ended; // sales will end in 30 days 

    constructor(string memory URI, uint initialMint) ERC721("Group NFT", "GNFT") {

        startingId();
        //Initial mint at time of deployment
        // 5 NFTs will be initially minted
        uint initialNFTs = initialMint;
        for(uint i; i<initialNFTs;i++){
        
        // count will start from 101
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        }
        
        maxSupplyCap = 50;
        BaseTokenURI = URI;
    }

    function startingId() internal {
            _tokenIdCounter._value = 101;
    }

    function _baseURI() internal view override returns (string memory) {
        return BaseTokenURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setPrice(uint newPrice)public onlyOwner{
        // initial price will be 0.001 ethers / 1000000000000000 wei
        price = newPrice;
    }
    function changeMaxLimit(uint newLimit)public onlyOwner{
        maxLimit = newLimit;
    }
    function startSales()public onlyOwner{
        launched = block.timestamp;
        ended = launched + 30 days;
    }

    function singleMint()public payable{
        require(totalSupply() <= maxSupplyCap,"Reached MAx Supply cap");
        require(balanceOf(msg.sender) <= maxLimit,"Maximum limit to buy is 5 NFt");
        require(msg.value == price, "pay correct price");
        require(ended > block.timestamp, "NFT sales has ended");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
       
    }

    //Bulk mint against eth max 5 NFTS 
     function BulkNfts(uint noOfNFTs)public payable{
        require(totalSupply() <= maxSupplyCap,"Reached MAx Supply cap");
        require(balanceOf(msg.sender) <= maxLimit,"Maximum limit to buy is 5 NFt");
        require(msg.value == (price * noOfNFTs), "Pay correct price for 5 Nfts");
        require(ended > block.timestamp, "NFT sales has ended");
        require(noOfNFTs <= 5, "Cant buy more than 5 NFTs at a time");

        uint bulk = noOfNFTs;
        
        for(uint i; i<bulk;i++){

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        }

     }

        //Buy initial minted nft against eth 
        function BuyFromInitialNFTs(uint NFT_Number)public payable{
            require(NFT_Number >= 101 || NFT_Number <= 105 , "This is not initial NFT Number");
            require(msg.value == price, "pay correct price");
            
            safeTransferFrom(owner(),msg.sender,NFT_Number);
       }
    
       fallback()external payable{
           singleMint();
       }
       receive()external payable{}
       
        //Funds withdrawal by owner
       function withrdaw()public payable{
            address receiver = owner();
            payable(receiver).transfer(address(this).balance);
       }

}
