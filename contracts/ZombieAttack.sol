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

    function randMod(uint256 _modulus) internal returns (uint256) {
        _randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, _randNonce)
                )
            ) % _modulus;
    }

    function attack(uint256 _zombieId, uint256 _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        require(
            ownerOf(_zombieId) != ownerOf(_targetId),
            "Cannot attack your own zombie"
        );
        bool win = false;
        uint256 rand = randMod(100);
        if (rand <= _attackVictoryProbability) {
            win = true;
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
        }
        emit Attacked(_zombieId, _targetId, ownerOf(_targetId), win);
    }
}
