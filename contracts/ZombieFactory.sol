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

    // Chainlink VRF
    VRFCoordinatorV2Interface internal COORDINATOR;
    uint64 internal subscriptionId;
    bytes32 internal keyHash;
    uint32 internal callbackGasLimit = 160000;
    uint16 internal requestConfirmations = 3;
    uint32 internal numWords = 1;

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

    struct Request {
        address requester;
        string zombieName;
    }

    struct AttackRequest {
        uint256 attackerId;
        uint256 targetId;
    }

    mapping(uint256 => AttackRequest) internal _attackRequests;
    mapping(uint256 => Request) internal _createRequests;

    Zombie[] public zombies;

    function _createZombie(
        address creator,
        string memory _name,
        uint256 _dna
    ) internal {
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
        _safeMint(creator, id);
        emit NewZombie(creator, id, _name, _dna);
    }

    function _createZombie(string memory _name, uint256 _dna) internal {
        _createZombie(msg.sender, _name, _dna);
    }

    function createRandomZombie(string memory _name) public {
        require(balanceOf(msg.sender) == 0, "You already have a zombie");
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        _createRequests[requestId] = Request(msg.sender, _name);
        emit RandomRequest(requestId, msg.sender);
    }
}
