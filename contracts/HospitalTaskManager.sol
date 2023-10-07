// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./PriorityHeap.sol";

contract HospitalTaskManager {
    address public owner;
    address public medicalStaffAddress; // Dirección del contrato MedicalStaff
    PriorityHeap public taskPriorityHeap;

    constructor(address _taskPriorityHeap) {
        owner = msg.sender;
        taskPriorityHeap = PriorityHeap(_taskPriorityHeap);
    }

    struct Caretaker {
        address caretakerAddress;
        string name;
        bool isActive;
    }

    struct Task {
        address assignedCaretakerAddress;
        address requester;
        bytes32 patientName;
        uint roomFrom;
        uint roomTo;
        uint bedNumber;
        uint priority;
        bool isAssigned;
        bool isStarted;
        bool isCompleted;
        uint startTime;
        uint endTime;
    }

    mapping(address => Caretaker) public caretakers;
    mapping(uint => Task) public tasks;
    uint public taskCount = 0;

    event TaskAssigned(uint taskId, address assignedCaretaker);
    event TaskStarted(uint taskId);
    event TaskCompleted(uint taskId, uint timeSpent);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    modifier onlyActiveCaretaker() {
        require(caretakers[msg.sender].isActive, "Only active caretakers are allowed");
        _;
    }

    modifier onlyAssignedCaretaker(uint taskId) {
        require(tasks[taskId].assignedCaretakerAddress == msg.sender, "Not the assigned caretaker for this task");
        _;
    }

    modifier onlyMedicalStaff() {
        require(msg.sender == medicalStaffAddress, "Only Medical Staff can execute this");
        _;
    }

    function setMedicalStaffAddress(address _medicalStaffAddress) public onlyOwner {
        medicalStaffAddress = _medicalStaffAddress;
    }

    function addCaretaker(address caretakerAddress, string memory name) public onlyOwner {
        caretakers[caretakerAddress] = Caretaker(caretakerAddress, name, true);
    }

    function removeCaretaker(address caretakerAddress) public onlyOwner {
        delete caretakers[caretakerAddress];
    }

    function activateCaretaker(address caretakerAddress) public onlyOwner {
        caretakers[caretakerAddress].isActive = true;
    }

    function deactivateCaretaker(address caretakerAddress) public onlyOwner {
        caretakers[caretakerAddress].isActive = false;
    }

    function assignTask(
        address requester,
        bytes32 patientName,
        uint roomFrom,
        uint roomTo,
        uint bedNumber,
        uint priority
    ) public onlyMedicalStaff {
        tasks[taskCount] = Task(msg.sender, requester, patientName, roomFrom, roomTo, bedNumber, priority, false, false, false, 0, 0);
        taskPriorityHeap.insert(taskCount, priority); 
        emit TaskAssigned(taskCount, msg.sender); 
        taskCount++;
    }

    function startTask(uint taskId) public onlyActiveCaretaker onlyAssignedCaretaker(taskId) {
        Task storage task = tasks[taskId];
        require(!task.isStarted, "Task already started");
        task.isStarted = true;
        task.startTime = block.timestamp;
        emit TaskStarted(taskId);
    }

    function endTask(uint taskId) public onlyActiveCaretaker onlyAssignedCaretaker(taskId) {
        Task storage task = tasks[taskId];
        require(task.isStarted && !task.isCompleted, "Task not started or already completed");
        task.isCompleted = true;
        task.endTime = block.timestamp;
        emit TaskCompleted(taskId, task.endTime - task.startTime);
    }

    function getTaskTime(uint taskId) public view returns (uint) {
        Task memory task = tasks[taskId];
        require(task.isCompleted, "Task not completed");
        return task.endTime - task.startTime;
    }
}
