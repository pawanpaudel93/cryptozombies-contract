//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieAttack.sol";

contract CryptoZombies is ZombieAttack {
    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _subscriptionId,
        address _vrfCoordinator
    ) ERC721(_name, _symbol) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
    }

    function kill() public onlyOwner {
        selfdestruct(payable(owner()));
    }
}
