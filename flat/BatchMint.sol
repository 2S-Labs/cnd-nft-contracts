// SPDX-License-Identifier: MIT

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File contracts/interfaces/IClonesneverdie.sol


pragma solidity ^0.8.10;

interface IClonesNeverDie {
	function safeMint(address to) external;
	function transferFrom(address from, address to, uint256 tokenId) external;
}


// File contracts/batch-mint/BatchMint.sol


pragma solidity ^0.8.10;

contract BatchMint {
	IClonesNeverDie public nft;
	address public devAddress;

	modifier onlyDev() {
		require(msg.sender == devAddress);
		_;
	}

	constructor(address ca) {
		devAddress = msg.sender;
		setNftCA(ca);
	}

	function batchMint(address to, uint256 num) public onlyDev {
		for (uint256 i = 0; i < num; i++) {
			nft.safeMint(to);
		}
	}

	function setDevAddress(address _devAddress) public onlyDev {
		devAddress = _devAddress;
	}

	function setNftCA(address ca) public onlyDev {
		nft = IClonesNeverDie(ca);
	}
}
