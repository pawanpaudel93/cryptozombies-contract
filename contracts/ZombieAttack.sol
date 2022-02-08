//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
    uint256 private randNonce = 0;
    uint256 private attackVictoryProbability = 70;

    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce = randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function attack(uint256 _zombieId, uint256 _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint256 rand = randMod(100);
        if (rand <= attackVictoryProbability) {
            myZombie.winCount = myZombie.winCount++;
            myZombie.level = myZombie.level++;
            enemyZombie.lossCount = enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount = myZombie.lossCount++;
            enemyZombie.winCount = enemyZombie.winCount++;
            _triggerCooldown(myZombie);
        }
    }
}