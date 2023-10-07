// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IHospitalTaskManager {
    function assignTask(
        address requester,
        bytes32 patientName,
        uint roomFrom,
        uint roomTo,
        uint bedNumber,
        uint priority
    ) external;
}

contract MedicalStaff {
    address public owner;
    IHospitalTaskManager public hospitalTaskManager;

    struct Staff {
        bool isAuthorized;
        bool isActive;
    }

    mapping(address => Staff) public staffMembers;

    constructor(address _hospitalTaskManager) {
        owner = msg.sender;
        hospitalTaskManager = IHospitalTaskManager(_hospitalTaskManager);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    function addStaff(address staffAddress) public onlyOwner {
        staffMembers[staffAddress] = Staff(true, true);
    }

    function removeStaff(address staffAddress) public onlyOwner {
        delete staffMembers[staffAddress];
    }

    function activateStaff() public {
        require(staffMembers[msg.sender].isAuthorized, "Not authorized");
        staffMembers[msg.sender].isActive = true;
    }

    function deactivateStaff() public {
        require(staffMembers[msg.sender].isAuthorized, "Not authorized");
        staffMembers[msg.sender].isActive = false;
    }

    function assignTaskToCaretaker(
        address requester,
        bytes32 patientName,
        uint roomFrom,
        uint roomTo,
        uint bedNumber,
        uint priority
    ) public {
        require(staffMembers[msg.sender].isAuthorized && staffMembers[msg.sender].isActive, "Not authorized or not active");
        hospitalTaskManager.assignTask(requester, patientName, roomFrom, roomTo, bedNumber, priority);
    }
}
