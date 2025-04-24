pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts@5.3.0/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts@5.3.0/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts@5.3.0/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts@5.3.0/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts@5.3.0/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @custom:security-contact shaekitchen1@gmail.com
contract SKCreativesNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ReentrancyGuard, EERC721Royalty {
    uint256 private _nextTokenId;
    uint256 private immutable i_mint_price;
    uint256 private immutable i_max_tokens;
    string private s_base_uri;
    string private s_token_uri_holder;
    address private immutable i_owner;

    event MintingCompleted(uint tokenId, address owner);
    event FundsDistributed(address owner, uint amount);

    constructor(        uint256 _mint_price,
        uint256 _max_tokens,
        string memory _base_uri,
        address _royaltyArtist,
        uint96 _royaltyBasis
        address initialOwner)
       
        ERC721("SKCreativesNFT", "MTK")
        Ownable(initialOwner)
    {        i_mint_price = _mint_price;
        i_max_tokens = _max_tokens;
        s_base_uri = _base_uri;
        _setDefaultRoyalty(_royaltyArtist, _royaltyBasis);
        i_owner = msg.sender;
        }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    function getBalance() view returns (uint) {
     return getUserBalance(msg.sender); // Return balance for current user.
}

    function depositForOwner(uint amount) external payable { 
        require(msg.sender == owner, "Only the owner can call this method");
        
       balances[owner] +=amount;  // Transfer funds from caller to contract
   }

function withdraw(uint amount) external nonReentrant{   
      require(amount <= getUserBalance(msg.sender), "Insufficient funds");  
      
     if (msg.sender==owner){
        payable(owner).transfer(getUserBalance(msg.sender));
    } else {
            payable(msg.sender).transfer(  getUserBalance( msg.sender)); 
          }
   }

// New function
function getUserBalance() public view returns (uint){
    return balances[msg.sender]; 

}
  receive() external payable {
        revert SKCreativesNFT__WrongAvenueForThisTransaction();
    }

    fallback() external payable {
        revert SKCreativesNFT__WrongAvenueForThisTransaction();
    }
   
    function safeMint(address to, string memory uri)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
    function mintTo(
        string calldata uri // ipfs url string
    ) public payable nonReentrant returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        // check or supply limits
        if (tokenId >= i_max_tokens) {
            revert SKCreativesNFT__MaxSupplyReached();
        }
        // make sure there us the right amount of money
        if (msg.value != i_mint_price) {
            revert SKCreativesNFT__ValueNotEqualPrice();
        }
        _tokenIdCounter++;
        uint256 newItemId = _tokenIdCounter;
        _safeMint(msg.sender, newItemId);
        emit MintingCompleted(newItemId, msg.sender);
        s_token_uri_holder = uri;
        _setTokenURI(newItemId, uri);
        payable(i_owner).transfer(address(this).balance);
        emit FundsDistributed(i_owner, msg.value);
        return newItemId;
    }

    function getMaxSupply() public view returns (uint256) {
        return i_max_tokens;
    }

    function getMintPrice() public view returns (uint256) {
        return i_mint_price;
    }

    function getBaseURI() public view returns (string memory) {
        return s_base_uri;
    }

    function contractURI() public view returns (string memory) {
        return s_base_uri;
    }

    function setRoyalty(
        // called by platform to set roylaty rates and artist payout address
        address _receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        _setDefaultRoyalty(_receiver, feeNumerator);
    }

    function _baseURI() internal view override returns (string memory) {
        return s_base_uri;
    }
    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
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
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
