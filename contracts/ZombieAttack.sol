//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieHelper.sol";

abstract contract ZombieAttack is ZombieHelper {
    uint256 private _randNonce = 0;
    uint256 private _attackVictoryProbability = 70;

    event Attacked(
        uint256 indexed attackerId,
        uint256 indexed targetId,
        address target,
        bool win
    );

    function _attack(
        uint256 _attackerId,
        uint256 _targetId,
        uint256 _randNumber
    ) internal {
        Zombie storage myZombie = zombies[_attackerId];
        Zombie storage enemyZombie = zombies[_targetId];
        bool win = false;
        if (_randNumber <= _attackVictoryProbability) {
            win = true;
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_attackerId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
        }
        emit Attacked(_attackerId, _targetId, ownerOf(_targetId), win);
    }

    function attack(uint256 _zombieId, uint256 _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        require(
            ownerOf(_zombieId) != ownerOf(_targetId),
            "Cannot attack your own zombie"
        );
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        _attackRequests[requestId] = AttackRequest(_zombieId, _targetId);
        emit RandomRequest(requestId, msg.sender);
    }
}
