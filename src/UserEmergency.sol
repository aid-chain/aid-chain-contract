// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract UserEmergency {

    enum EmergencyType {Water, Food, Tent, UnderRubble, UnderDanger, SpecialNeed, WorkMachine}

    struct EmergencyCall {
        address creator;
        uint64 lat; // total 19 digits , 16 decimals for after dot.
        uint64 len; // total 19 digits , 16 decimals for after dot.
        EmergencyType emergencyType;
        uint8 urgencyRate;
        string explanation;
        uint256 timeStamp;
        bytes32 id;
    }
    struct EmergencyCallWithNoId {
        uint64 lat;
        uint64 len;
        EmergencyType emergencyType;
        uint8 urgencyRate;
        string explanation;
        uint256 timeStamp;
    }

    mapping(bytes32 id => EmergencyCall emergencyCall) public s_EmergencyCalls;
    mapping(EmergencyType emergencyType => bytes32[] ids) public s_EmergencyTypeToIdArray;

    event EmergencyCallCreatedEvent(
        address creator,
        uint64 lat,
        uint64 len,
        EmergencyType emergencyType,
        uint8 urgencyRate,
        string explanation,
        uint256 timeStamp,
        bytes32 id
    );

    function createEmergencyCall(EmergencyCallWithNoId memory _emergencyCallWithNoId) public {

        bytes32 id = keccak256(abi.encodePacked(
            msg.sender, 
            _emergencyCallWithNoId.lat, 
            _emergencyCallWithNoId.len, 
            _emergencyCallWithNoId.emergencyType, 
            _emergencyCallWithNoId.urgencyRate, 
            _emergencyCallWithNoId.explanation, 
            _emergencyCallWithNoId.timeStamp));

        s_EmergencyCalls[id] = EmergencyCall({
            creator: msg.sender,
            lat: _emergencyCallWithNoId.lat,
            len: _emergencyCallWithNoId.len,
            emergencyType: _emergencyCallWithNoId.emergencyType,
            urgencyRate: _emergencyCallWithNoId.urgencyRate,
            explanation: _emergencyCallWithNoId.explanation,
            timeStamp: _emergencyCallWithNoId.timeStamp,
            id: id
        });
        s_EmergencyTypeToIdArray[_emergencyCallWithNoId.emergencyType].push(id);
        
        emit EmergencyCallCreatedEvent(
            msg.sender, 
            _emergencyCallWithNoId.lat, 
            _emergencyCallWithNoId.len, 
            _emergencyCallWithNoId.emergencyType, 
            _emergencyCallWithNoId.urgencyRate, 
            _emergencyCallWithNoId.explanation, 
            _emergencyCallWithNoId.timeStamp, 
            id);
    }
    function createEmergencyCallBundle(EmergencyCallWithNoId[] memory _emergencyCallWithNoIdArray) public {
        for(uint256 i = 0; i < _emergencyCallWithNoIdArray.length; i++) {
            createEmergencyCall(_emergencyCallWithNoIdArray[i]);
        }
    }
   
    function getIdArray(EmergencyType emergencyType) public view returns (bytes32[] memory ids) {
        require(s_EmergencyTypeToIdArray[emergencyType].length != 0, "There is no id with this type");
        return s_EmergencyTypeToIdArray[emergencyType];
    }

    function getEmergencyCallById(bytes32 id) public view returns (EmergencyCall memory) {
        return s_EmergencyCalls[id];
    }  
}
