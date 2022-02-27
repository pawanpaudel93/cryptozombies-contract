//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ZombieAttack.sol";

contract CryptoZombies is ZombieAttack {
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}
}
