// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/Strings.sol";
import "../openzeppelin/contracts/access/Ownable.sol";
import "../openzeppelin/contracts/security/Pausable.sol";
import "../openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "../openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract ClonesNeverDieAsset is Context, ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {
	using Strings for uint256;

	event SetAssetType(uint256 indexed id, uint256 indexed _type);
	event SetBlacklist(address indexed user, bool status);

	string private baseURI;
	string public constant NAME = "Clones Never Die Asset";
	string public constant SYMBOL = "CNDASS";
	address public devAddress;
	address public mintContract;
	address public proxyContract;

	mapping(uint256 => uint256) internal assetType;
	mapping(address => bool) public blacklist;

	modifier onlyDev() {
		require(_msgSender() == devAddress);
		_;
	}

	modifier onlyMinter() {
		require(_msgSender() == mintContract);
		_;
	}

	constructor(address _dev, string memory _baseURI) ERC1155(_baseURI) {
		baseURI = _baseURI;
		setDevAddress(_dev);
	}

	function setURI(string memory newuri) public onlyDev {
		_setURI(newuri);
	}

	function pause() public onlyDev {
		_pause();
	}

	function unpause() public onlyDev {
		_unpause();
	}

	function mint(
		address account,
		uint256 id,
		uint256 amount,
		bytes memory data,
		uint256 _type
	) public onlyMinter {
		_mint(account, id, amount, data);
		_setAssetType(id, _type);
	}

	function mintBatch(
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data,
		uint256[] memory _types
	) public onlyMinter {
		_mintBatch(to, ids, amounts, data);
		_setAssetTypeBatch(ids, _types);
	}

	function setDevAddress(address _devAddress) public onlyOwner {
		devAddress = _devAddress;
	}

	function setMintContract(address _ca) public onlyDev {
		mintContract = _ca;
	}

	function setProxyContract(address _ca) public onlyDev {
		proxyContract = _ca;
	}

	function setBlacklist(address user, bool status) external onlyDev {
		blacklist[user] = status;
		emit SetBlacklist(user, status);
	}

	function name() external pure returns (string memory) {
		return NAME;
	}

	function symbol() external pure returns (string memory) {
		return SYMBOL;
	}

	function uri(uint256 tokenId) public view virtual override returns (string memory) {
		require(exists(tokenId), "ERC1155Supply: URI query for nonexistent token");
		return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
	}

	function isApprovedForAll(address _owner, address _operator) public view override returns (bool isOperator) {
		if (_operator == proxyContract) {
			return true;
		}
		return super.isApprovedForAll(_owner, _operator);
	}

	function getAssetType(uint256 id) public view returns (uint256) {
		return assetType[id];
	}

	function _setAssetType(uint256 _id, uint256 _type) internal {
		assetType[_id] = _type;
		emit SetAssetType(_id, _type);
	}

	function _setAssetTypeBatch(uint256[] memory _ids, uint256[] memory _types) internal {
		for (uint256 i = 0; i < _ids.length; i++) {
			_setAssetType(_ids[i], _types[i]);
			// assetType[_ids[i]] = _types[i];
		}
	}

	function _beforeTokenTransfer(
		address operator,
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	) internal override(ERC1155, ERC1155Supply) whenNotPaused {
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
		require(!blacklist[from] && !blacklist[to], "BLACKLIST");
	}
}
