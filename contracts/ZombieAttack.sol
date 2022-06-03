//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieHelper.sol";

abstract contract ZombieAttack is ZombieHelper {
    uint256 private constant ATTACK_VICTORY_PROBABILITY = 70;

    event Attacked(
        uint256 indexed attackerId,
        uint256 indexed targetId,
        address target,
        bool win
    );

    function _attack(
        address attacker,
        uint256 attackerId,
        uint256 targetId,
        uint256 randNumber
    ) internal {
        Zombie storage myZombie = zombies[attackerId];
        Zombie storage enemyZombie = zombies[targetId];
        bool win = randNumber >= ATTACK_VICTORY_PROBABILITY;
        if (win) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            _feedAndMultiply(attacker, attackerId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
        }
        emit Attacked(attackerId, targetId, ownerOf(targetId), win);
    }

    function attack(uint256 zombieId, uint256 targetId)
        external
        onlyOwnerOf(zombieId)
    {
        require(
            ownerOf(zombieId) != ownerOf(targetId),
            "Cannot attack your own zombie"
        );
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );
        _attackRequests[requestId] = AttackRequest(
            msg.sender,
            zombieId,
            targetId
        );
        emit RandomRequest(requestId, msg.sender);
    }
}
