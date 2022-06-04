//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

abstract contract ZombieFactory is ERC721, Ownable, VRFConsumerBaseV2 {
    event NewZombie(
        address indexed creator,
        uint256 zombieId,
        string name,
        uint256 dna
    );
    event RandomRequest(uint256 indexed requestId, address indexed requester);

    struct Zombie {
        string name;
        uint256 id;
        uint256 dna;
        uint64 level;
        uint64 readyTime;
        uint64 winCount;
        uint64 lossCount;
    }

    struct Request {
        address requester;
        string zombieName;
    }

    struct AttackRequest {
        address attacker;
        uint256 attackerId;
        uint256 targetId;
    }

    // Chainlink VRF
    VRFCoordinatorV2Interface internal COORDINATOR;
    uint64 internal subscriptionId;
    bytes32 internal keyHash;
    uint32 internal constant CALLBACK_GAS_LIMIT = 170000;
    uint16 internal constant REQUEST_CONFIRMATIONS = 3;
    uint32 internal constant NUM_WORDS = 1;
    uint256 private constant DNA_DIGITS = 16;
    uint256 internal constant DNA_MODULUS = 10**DNA_DIGITS;
    uint256 internal constant COOLDOWN_TIME = 1 days;

    Zombie[] public zombies;
    mapping(uint256 => AttackRequest) internal _attackRequests;
    mapping(uint256 => Request) internal _createRequests;
    mapping(address => bool) public randomZombieRequested;

    function _createZombie(
        address creator,
        string memory name,
        uint256 dna
    ) internal {
        uint256 id = zombies.length;
        zombies.push(
            Zombie(
                name,
                id,
                dna,
                1,
                uint64(block.timestamp + COOLDOWN_TIME),
                0,
                0
            )
        );
        _safeMint(creator, id);
        emit NewZombie(creator, id, name, dna);
    }

    function _createZombie(string memory name, uint256 dna) internal {
        _createZombie(msg.sender, name, dna);
    }

    function createRandomZombie(string memory name) public {
        require(balanceOf(msg.sender) == 0, "You already have a zombie");
        require(randomZombieRequested[msg.sender] == false, "You already requested a zombie");
        randomZombieRequested[msg.sender] = true;
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );
        _createRequests[requestId] = Request(msg.sender, name);
        emit RandomRequest(requestId, msg.sender);
    }
}
