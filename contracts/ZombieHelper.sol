//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieFeeding.sol";

abstract contract ZombieHelper is ZombieFeeding {
    uint256 public levelUpFee = 0.001 ether;

    modifier aboveLevel(uint256 level, uint256 zombieId) {
        require(zombies[zombieId].level >= level, "Zombie is not above level");
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setLevelUpFee(uint256 fee) external onlyOwner {
        levelUpFee = fee;
    }

    function levelUp(uint256 zombieId) external payable {
        require(msg.value == levelUpFee, "Not enough ether");
        zombies[zombieId].level++;
    }

    function changeName(uint256 zombieId, string memory newName)
        external
        aboveLevel(2, zombieId)
        onlyOwnerOf(zombieId)
    {
        zombies[zombieId].name = newName;
    }

    function changeDna(uint256 zombieId, uint256 newDna)
        external
        aboveLevel(20, zombieId)
        onlyOwnerOf(zombieId)
    {
        zombies[zombieId].dna = newDna;
    }

    function getZombiesByOwner(address owner)
        external
        view
        returns (Zombie[] memory)
    {
        Zombie[] memory ownerZombies = new Zombie[](balanceOf(owner));
        uint256 counter = 0;
        for (uint256 i = 0; i < zombies.length; i++) {
            if (ownerOf(i) == owner) {
                ownerZombies[counter] = zombies[i];
                counter++;
            }
        }
        return ownerZombies;
    }

    function getZombies(uint256 startIndex, uint256 totalSize)
        external
        view
        returns (Zombie[] memory)
    {
        if (startIndex > zombies.length) {
            return new Zombie[](0);
        }
        uint256 _endIndex = startIndex + totalSize;
        if (_endIndex > zombies.length) {
            _endIndex = zombies.length;
        }
        Zombie[] memory zombiesToReturn = new Zombie[](_endIndex - startIndex);
        for (uint256 i = startIndex; i < _endIndex; i++) {
            zombiesToReturn[i - startIndex] = zombies[i];
        }
        return zombiesToReturn;
    }
}
