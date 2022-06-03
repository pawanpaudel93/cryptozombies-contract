//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ZombieFactory.sol";

interface KittyInterface {
    function getKitty(uint256 _id)
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

abstract contract ZombieFeeding is ZombieFactory {
    KittyInterface private kittyContract;

    modifier onlyOwnerOf(uint256 zombieId) {
        require(
            msg.sender == ownerOf(zombieId),
            "Not the owner of this zombie"
        );
        _;
    }

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    function _triggerCooldown(Zombie storage zombie) internal {
        zombie.readyTime = uint64(block.timestamp + COOLDOWN_TIME);
    }

    function _isReady(Zombie storage zombie) internal view returns (bool) {
        return (zombie.readyTime <= block.timestamp);
    }

    function _feedAndMultiply(
        address attacker,
        uint256 zombieId,
        uint256 targetDna,
        string memory species
    ) internal {
        Zombie storage myZombie = zombies[zombieId];
        require(_isReady(myZombie), "Zombie is not ready");
        targetDna = targetDna % DNA_MODULUS;
        uint256 newDna = (myZombie.dna + targetDna) / 2;

        if (
            keccak256(abi.encodePacked(species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie(attacker, "NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 zombieId, uint256 kittyId) public {
        uint256 kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(kittyId);
        _feedAndMultiply(msg.sender, zombieId, kittyDna, "kitty");
    }
}
