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

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        Request storage createRequest = _createRequests[requestId];
        if (createRequest.requester != address(0)) {
            uint256 randDna = randomWords[0] % dnaModulus;
            _createZombie(
                createRequest.requester,
                createRequest.zombieName,
                randDna
            );
        } else {
            AttackRequest storage attackRequest = _attackRequests[requestId];
            _attack(
                attackRequest.attackerId,
                attackRequest.targetId,
                randomWords[0]
            );
        }
    }
}
