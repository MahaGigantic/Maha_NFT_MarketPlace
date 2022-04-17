// SPDX-License-Identifier: MIT
/**
 * @dev This contract uses OpenZeppeling standard libraries along with
 * MahaNFTContract and MahaTokenContract.
*/
pragma solidity ^0.8.0;
/**
 * @dev Import Counters.sol from OpenZeppeling standard libraries along with
 * MahaNFTContract.sol and MahaTokenContract.sol
*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Counters.sol";
import "./MahaNFTContract.sol";
import "./MahaTokenContract.sol";

/**
*  @dev creating MahaNFTMarketplace contract which is a child of MahaNFTContract
*   
*/
contract MahaNFTMarketplace is MahaNFTContract {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;
    Counters.Counter private _soldItems;
   MahaTokenContract private tokenContract;

    uint256 listingPrice = 25;
    address payable _owner;

    mapping(uint256 => MahaNFTMarketItem) private _idToMahaNFTMarketItem;

    struct MahaNFTMarketItem {
      uint256 _tokenID;
      address payable _seller;
      address payable _owner;
      uint256 _price;
      bool _isSold;
    }

    event MahaNFTMarketItemCreated (
      uint256 indexed _tokenID,
      address __seller,
      address _owner,
      uint256 _price,
      bool _isSold
    );
//MahaTokenContract()
    constructor() MahaNFTContract(){
      _owner = payable(msg.sender);
    }

    /* Updates the listing _price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(_owner == msg.sender, string(abi.encodePacked("Only marketplace _owner can update listing _price in ",tokenContract.name)));
      require(_listingPrice > 0, string(abi.encodePacked("Price must be at least 1",tokenContract.name)));
      listingPrice = _listingPrice;
    }

    /* Returns the listing _price of the contract */
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 _price) public payable returns (uint) {
      _tokenIDs.increment();
      uint256 newTokenId = _tokenIDs.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMahaNFTMarketItem(newTokenId, _price);
      return newTokenId;
    }

    function createMahaNFTMarketItem(
      uint256 _tokenID,
      uint256 _price
    ) private {
      require(_price > 0, string(abi.encodePacked("Price must be at least 1",tokenContract.name)));
      
      require(msg.value == listingPrice, string(abi.encodePacked("Price must be equal to listing _price in ",tokenContract.name)));

      _idToMahaNFTMarketItem[_tokenID] =  MahaNFTMarketItem(
        _tokenID,
        payable(msg.sender),
        payable(address(this)),
        _price,
        false
      );

      _transfer(msg.sender, address(this), _tokenID);
      emit MahaNFTMarketItemCreated(
        _tokenID,
        msg.sender,
        address(this),
        _price,
        false
      );
    }

    /* allows someone to resell a token they have purchased */
    function sell(uint256 _tokenID, uint256 _price) public payable {
      require(_idToMahaNFTMarketItem[_tokenID]._owner == msg.sender, "Only item _owner can perform this operation");
      require(msg.value == listingPrice, string(abi.encodePacked("Price must be equal to listing _price in ",tokenContract.name)));
      _idToMahaNFTMarketItem[_tokenID]._isSold = false;
      _idToMahaNFTMarketItem[_tokenID]._price = _price;
      _idToMahaNFTMarketItem[_tokenID]._seller = payable(msg.sender);
      _idToMahaNFTMarketItem[_tokenID]._owner = payable(address(this));
      _soldItems.decrement();

      _transfer(msg.sender, address(this), _tokenID);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers _ownership of the item, as well as funds between parties */
    function createMarketSale(
      uint256 _tokenID
      ) public payable {
      uint _price = _idToMahaNFTMarketItem[_tokenID]._price;
      address _seller = _idToMahaNFTMarketItem[_tokenID]._seller;
      require(msg.value == _price, "Please submit the asking _price in order to complete the purchase");
      _idToMahaNFTMarketItem[_tokenID]._owner = payable(msg.sender);
      _idToMahaNFTMarketItem[_tokenID]._isSold = true;
      _idToMahaNFTMarketItem[_tokenID]._seller = payable(address(0));
      _soldItems.increment();
      _transfer(address(this), msg.sender, _tokenID);
      payable(_owner).transfer(listingPrice);
      payable(_seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MahaNFTMarketItem[] memory) {
      uint itemCount = _tokenIDs.current();
      uint unsoldItemCount = _tokenIDs.current() - _soldItems.current();
      uint currentIndex = 0;

      MahaNFTMarketItem[] memory items = new MahaNFTMarketItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (_idToMahaNFTMarketItem[i + 1]._owner == address(this)) {
          uint currentId = i + 1;
          MahaNFTMarketItem storage currentItem = _idToMahaNFTMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyMahaNFTs() public view returns (MahaNFTMarketItem[] memory) {
      uint totalItemCount = _tokenIDs.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (_idToMahaNFTMarketItem[i + 1]._owner == msg.sender) {
          itemCount += 1;
        }
      }

      MahaNFTMarketItem[] memory items = new MahaNFTMarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (_idToMahaNFTMarketItem[i + 1]._owner == msg.sender) {
          uint currentId = i + 1;
          MahaNFTMarketItem storage currentItem = _idToMahaNFTMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items a user has listed */
    function fetchMahaNFTItemsListed() public view returns (MahaNFTMarketItem[] memory) {
      uint totalItemCount = _tokenIDs.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (_idToMahaNFTMarketItem[i + 1]._seller == msg.sender) {
          itemCount += 1;
        }
      }

      MahaNFTMarketItem[] memory items = new MahaNFTMarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (_idToMahaNFTMarketItem[i + 1]._seller == msg.sender) {
          uint currentId = i + 1;
          MahaNFTMarketItem storage currentItem = _idToMahaNFTMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}