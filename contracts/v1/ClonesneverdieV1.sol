// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../openzeppelin/contracts/security/Pausable.sol";
import "../openzeppelin/contracts/access/Ownable.sol";
import "../openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../openzeppelin/contracts/utils/Counters.sol";

contract ClonesNeverDieV1 is ERC721, ERC721Enumerable, Pausable, Ownable, ERC721Burnable {
	using Counters for Counters.Counter;
	event SetBlacklist(address indexed user, bool status);
	event SetFreeze(uint256 indexed tokenId, bool status);

	string private _baseTokenURI;
	uint256 internal MAX_NFT_SUPPLY = 100;
	address public devAddress;
	address public mintContract;
	address public freezeContract;

	mapping(address => bool) public blacklist;
	mapping(uint256 => bool) public freeze;

	Counters.Counter private _tokenIdCounter;

	constructor(address _dev) ERC721("Clones Never Die V1", "CNDV1") {
		_tokenIdCounter.increment();
    setDevAddress(_dev);
	}

	modifier onlyDev() {
		require(_msgSender() == devAddress);
		_;
	}

	modifier onlyMinter() {
		require(_msgSender() == mintContract);
		_;
	}

	modifier onlyFreezer() {
		require(_msgSender() == freezeContract);
		_;
	}

	function safeMint(address to) public onlyMinter {
		require(totalSupply() < MAX_NFT_SUPPLY, "Mint end.");
		uint256 tokenId = _tokenIdCounter.current();
		_tokenIdCounter.increment();
		_safeMint(to, tokenId);
	}

	function transferFrom(
		address from,
		address to,
		uint256 tokenId
	) public virtual override {
		require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    require(!freeze[tokenId], "This token is frozen");
		require(!blacklist[from] && !blacklist[to], "BLACKLIST");
		_transfer(from, to, tokenId);
	}

	function safeTransferFrom(
		address from,
		address to,
		uint256 tokenId,
		bytes memory _data
	) public virtual override {
		require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    require(!freeze[tokenId], "This token is frozen");
		require(!blacklist[from] && !blacklist[to], "BLACKLIST");
		_safeTransfer(from, to, tokenId, _data);
	}

	function pause() public onlyDev {
		_pause();
	}

	function unpause() public onlyDev {
		_unpause();
	}

  function setDevAddress(address _devAddress) public onlyOwner {
		devAddress = _devAddress;
	}

	function setBaseURI(string memory baseURI) public onlyDev {
		_baseTokenURI = baseURI;
	}

	function setMintContract(address _ca) public onlyDev {
		mintContract = _ca;
	}

  function setFreezeContract(address _ca) public onlyDev {
		freezeContract = _ca;
	}

	function setBlacklist(address user, bool status) external onlyDev {
		blacklist[user] = status;
		emit SetBlacklist(user, status);
	}

	function setFreeze(uint256 tokenId, bool status) public onlyFreezer {
		freeze[tokenId] = status;
		emit SetFreeze(tokenId, status);
	}

	function _baseURI() internal view override returns (string memory) {
		return _baseTokenURI;
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal override(ERC721, ERC721Enumerable) whenNotPaused {
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}
}