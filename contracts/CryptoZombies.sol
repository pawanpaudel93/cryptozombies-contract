//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieAttack.sol";

contract CryptoZombies is ZombieAttack {
    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) ERC721(_name, _symbol) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    function kill() public onlyOwner {
        selfdestruct(payable(owner()));
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
            uint256 randDna = randomWords[0] % dnaModulus;
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
