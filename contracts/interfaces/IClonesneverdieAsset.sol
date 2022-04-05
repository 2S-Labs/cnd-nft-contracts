// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IClonesNeverDieAsset {
	function mint(address account, uint256 id, uint256 amount, bytes memory data) external;

	function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

	function burn(address account, uint256 id, uint256 value) external;

	function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external;

	function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

	function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

	function setApprovalForAll(address operator, bool approved) external;

	function totalSupply(uint256 id) external view returns (uint256);

	function exists(uint256 id) external view returns (bool);

	function balanceOf(address account, uint256 id) external view returns (uint256);

	function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external view returns (uint256[] memory);

	function getAssetType(uint256 id) external view returns (uint256);
}
