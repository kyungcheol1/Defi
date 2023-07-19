//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Timelock {
    using SafeMath for uint;

    address private admin;

    struct StableState {
        bool status;
        bool canceled;
        uint256 blockTime;
        bool close;
    }

    mapping(bytes32 => StableState) private proposals;

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 10;
    uint public constant MAXIMUM_DELAY = 30 days;

    uint delay;

    constructor(uint _delay, address _admin) {
        require(
            _delay > MINIMUM_DELAY,
            "Timelock : Delay must be longer than 2 days."
        );
        require(
            _delay < MAXIMUM_DELAY,
            "Timelock : Delay must be less than 30 days."
        );

        admin = _admin;
        delay = _delay;
    }

    function setDelay(uint _delay) public {
        require(
            _delay > MINIMUM_DELAY,
            "Timelock : Delay must be longer than 2 days."
        );
        require(
            _delay < MAXIMUM_DELAY,
            "Timelock : Delay must be less than 30 days."
        );

        delay = _delay;
    }

    function queueTransaction(
        bytes memory _callFunction,
        uint256 _blockTime
    ) public {
        bytes32 hashdata = keccak256(_callFunction);
        if (proposals[hashdata].blockTime == 0) {
            proposals[hashdata] = StableState(false, false, _blockTime, false);
        }
    }

    function cancelTransaction(
        bytes memory _callFunction
    ) public returns (bool) {
        require(msg.sender == admin, "Timelock :  only owner");
        bytes32 hashdata = keccak256(_callFunction);
        proposals[hashdata].canceled = true;
        return true;
    }

    function executeTransaction(
        bytes memory _callFunction,
        uint256 etc
    ) public returns (bool) {
        require(msg.sender == admin, "Timelock :  only owner");
        bytes32 hashdata = keccak256(_callFunction);
        require(
            etc > proposals[hashdata].blockTime.add(delay),
            "Timelock : no timing"
        );
        proposals[hashdata].status = true;
        return true;
    }

    function getTransaction(
        bytes memory _callFunction
    ) public view returns (StableState memory) {
        bytes32 hashdata = keccak256(_callFunction);
        return proposals[hashdata];
    }

    function getHash(bytes memory _callFunction) public pure returns (bytes32) {
        return keccak256(_callFunction);
    }

    function closePropose(bytes memory funcName) public returns (bool) {
        proposals[keccak256(funcName)].close = true;
        return true;
    }
}