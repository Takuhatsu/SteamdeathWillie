// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/// @title: Steamdeath Willie™
/// @author: Takuhatsu
/// Didg loves Mickey and eastereggs

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SteamdeathWillieBlackMarket is ERC721, ERC721Enumerable, Ownable {
    string internal nftName = "Steamdeath";
    string internal nftSymbol = "STDW";

    string _baseTokenURI;

    uint16 public constant freeWilliesLimit = 4;
    uint16 public currentFreeWillies = 0;
    uint16 public constant totalWillies = 10000;
    uint16 public constant maxWilliesPurchase = 20;
    uint64 public constant williePrice = 7000000000000000; // 0.007eth

    uint256 private mintedWillies;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    using Strings for uint256;
    using SafeMath for uint256;

    constructor() ERC721(nftName, nftSymbol) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getWillie(uint16 numWillies) public payable {
        require(
            numWillies > 0 && numWillies <= maxWilliesPurchase,
            "You can mint between 1 and 20 Willies per transaction"
        );

        uint256 totalCost = numWillies * williePrice;
        require(msg.value >= totalCost, "Insufficient funds");

        require(
            totalSupply().add(numWillies) <= totalWillies,
            "All Willies are minted"
        );

        for (uint16 i = 0; i < numWillies; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }
    }

    function getFreeWillie() public {
        require(
            currentFreeWillies < freeWilliesLimit,
            "All free Willies are minted"
        );
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
            currentFreeWillies++;
    }

    function williesRemained() public view returns (uint256) {
        uint256 williesMinted = totalSupply();
        uint256 _williesRemained = uint256(totalWillies).sub(
            williesMinted
        );
        if (williesMinted == 0) {
            return totalWillies;
        } else {
            return _williesRemained;
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        address dWallet = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        uint256 halfBalance = balance / 2;
        payable(owner()).transfer(halfBalance);
        payable(dWallet).transfer(halfBalance);
    }

    // OVERRIDES

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
