//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ZombieFactory is ERC721, Ownable {
    event NewZombie(
        address indexed creator,
        uint256 zombieId,
        string name,
        uint256 dna
    );

    uint256 public dnaDigits = 16;
    uint256 public dnaModulus = 10**dnaDigits;
    uint256 public cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint256 id;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    function _createZombie(string memory _name, uint256 _dna) internal {
        uint256 id = zombies.length;
        zombies.push(
            Zombie(
                _name,
                id,
                _dna,
                1,
                uint32(block.timestamp + cooldownTime),
                0,
                0
            )
        );
        _safeMint(msg.sender, id);
        emit NewZombie(msg.sender, id, _name, _dna);
    }

    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        require(balanceOf(msg.sender) == 0, "You already have a zombie");
        uint256 randDna = _generateRandomDna(_name);
        randDna = randDna - (randDna % 100);
        _createZombie(_name, randDna);
    }
}
