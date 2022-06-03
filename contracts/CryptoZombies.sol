//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieAttack.sol";

contract CryptoZombies is ZombieAttack {
    constructor(
        string memory name,
        string memory symbol,
        uint64 _subscriptionId,
        address vrfCoordinator,
        bytes32 _keyHash
    ) ERC721(name, symbol) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        Request memory createRequest = _createRequests[requestId];
        AttackRequest memory attackRequest = _attackRequests[requestId];
        require(
            createRequest.requester != address(0) ||
                attackRequest.attacker != address(0),
            "Invalid request"
        );

        if (createRequest.requester != address(0)) {
            uint256 randDna = randomWords[0] % DNA_MODULUS;
            delete _createRequests[requestId];
            _createZombie(
                createRequest.requester,
                createRequest.zombieName,
                randDna
            );
        } else {
            delete _attackRequests[requestId];
            _attack(
                attackRequest.attacker,
                attackRequest.attackerId,
                attackRequest.targetId,
                randomWords[0] % 100
            );
        }
    }
}
