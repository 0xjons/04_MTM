// MedicalStaff.sol
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
        uint priority; // Nuevo campo para la prioridad del personal
    }

    mapping(address => Staff) public staffMembers;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    function addStaff(address staffAddress, uint _priority) public onlyOwner {
        staffMembers[staffAddress] = Staff(true, true, _priority);
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

    function getStaffPriority(address staffAddress) public view returns (uint) {
        return staffMembers[staffAddress].priority;
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

    function setHospitalTaskManager(address _hospitalTaskManager) public onlyOwner {
    hospitalTaskManager = IHospitalTaskManager(_hospitalTaskManager);
}

}

