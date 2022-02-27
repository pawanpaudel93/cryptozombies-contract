//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ZombieFeeding.sol";

abstract contract ZombieHelper is ZombieFeeding {
    uint256 public levelUpFee = 0.001 ether;

    modifier aboveLevel(uint256 _level, uint256 _zombieId) {
        require(
            zombies[_zombieId].level >= _level,
            "Zombie is not above level"
        );
        _;
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        payable(_owner).transfer(address(this).balance);
    }

    function setLevelUpFee(uint256 _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function levelUp(uint256 _zombieId) external payable {
        require(msg.value == levelUpFee, "Not enough ether");
        zombies[_zombieId].level++;
    }

    function changeName(uint256 _zombieId, string memory _newName)
        external
        aboveLevel(2, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint256 _zombieId, uint256 _newDna)
        external
        aboveLevel(20, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner)
        external
        view
        returns (Zombie[] memory)
    {
        Zombie[] memory ownerZombies = new Zombie[](balanceOf(_owner));
        uint256 counter = 0;
        for (uint256 i = 0; i < zombies.length; i++) {
            if (ownerOf(i) == _owner) {
                ownerZombies[counter] = zombies[i];
                counter++;
            }
        }
        return ownerZombies;
    }

    function getZombies(uint256 _startIndex, uint256 _totalSize)
        external
        view
        returns (Zombie[] memory)
    {
        if (_startIndex > zombies.length) {
            return new Zombie[](0);
        }
        uint256 _endIndex = _startIndex + _totalSize;
        if (_endIndex > zombies.length) {
            _endIndex = zombies.length;
        }
        Zombie[] memory zombiesToReturn = new Zombie[](_endIndex - _startIndex);
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            zombiesToReturn[i - _startIndex] = zombies[i];
        }
        return zombiesToReturn;
    }
}
