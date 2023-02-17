//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract QuadraticFunding is Initializable {
    uint public START;
    uint public EXPIRY;
    uint public NET_DONATED;
    uint public NET_ROOT_DONATED;
    uint public POOL;

    uint[] public projectList;

    mapping(uint => string) public projectMetadata;
    mapping(address => bool) public projectCreated;
    mapping(uint => address) public projectCreator;
    mapping(uint => uint) public donatedAmountRoot;

    function init(uint start, uint expiry) external payable initializer {
        START = start;
        EXPIRY = expiry;
        POOL = msg.value;
    }

    function createProject(string memory metadata) external {
        // require(
        //     !projectCreated[msg.sender],
        //     "ERROR: USER ALREADY SUBMITTED PROJECT"
        // );
        projectCreated[msg.sender] = true;
        projectMetadata[projectList.length] = metadata;
        projectCreator[projectList.length] = msg.sender;
        projectList.push(0);
    }

    function editProjectMetadata(
        string memory newMetadata,
        uint projectId
    ) external {
        require(projectCreator[projectId] == msg.sender, "ERROR: NOT CREATOR");
        projectMetadata[projectId] = newMetadata;
    }

    function donate(uint projectId) external payable {
        require(projectId <= projectList.length, "ERROR: INVALID ID");
        require(
            projectCreator[projectId] != msg.sender,
            "ERROR: CREATOR CAN'T DONATE"
        );
        require(block.timestamp < EXPIRY, "ERROR: EVENT EXPIRED");
        require(block.timestamp > START, "ERROR: EVENT NOT STARTED");
        projectList[projectId] += msg.value;
        uint rootValue = sqrt(msg.value);
        updateNetRootDonation(
            projectId,
            donatedAmountRoot[projectId] + rootValue
        );
        donatedAmountRoot[projectId] += rootValue;
        NET_DONATED += msg.value;
    }

    function retrieveMatching(uint projectId) external {
        require(projectCreator[projectId] == msg.sender, "ERROR: NOT CREATOR");
        require(block.timestamp > EXPIRY, "ERROR: EVENT NOT EXPIRED");
        uint matching = ((donatedAmountRoot[projectId] ** 2) * POOL) /
            NET_ROOT_DONATED;
        uint toTransfer = projectList[projectId] + matching;
        projectList[projectId] = 0;
        donatedAmountRoot[projectId] = 0;
        payable(msg.sender).transfer(toTransfer);
    }

    function checkMatching(uint projectId) external view returns (uint) {
        return ((donatedAmountRoot[projectId] ** 2) * POOL) / NET_ROOT_DONATED;
    }

    function updateNetRootDonation(uint projectId, uint amount) private {
        NET_ROOT_DONATED -= donatedAmountRoot[projectId] ** 2;
        NET_ROOT_DONATED += amount ** 2;
    }

    function getTotalProjects() external view returns (uint) {
        return projectList.length;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
