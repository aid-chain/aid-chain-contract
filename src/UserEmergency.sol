// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract UserEmergency {

    error UserEmergency_IdCouldntFind();

    enum EmergencyType {Water, Food, Tent, UnderRubble, UnderDanger, SpecialNeed, WorkMachine, Custom}

    struct EmergencyReport {
    address creator;
    uint64 lat; // total 19 digits,  16 decimals for after dot.
    uint64 len; // total 19 digits,  16 decimals for after dot.
    EmergencyType emergencyType;
    uint8 urgencyRate;
    string description;
    uint256 timeStamp;
    bytes32 id;
    uint256 approvalCount;
    uint256 disapprovalCount;
    }

    struct EmergencyReportWithNoId {
        uint64 lat;
        uint64 len;
        EmergencyType emergencyType;
        uint8 urgencyRate;
        string description;
        uint256 timeStamp;
    }

    struct Information {
        address creator;
        uint64 lat; // total 19 digits , 16 decimals for after dot. 
        uint64 len; // total 19 digits , 16 decimals for after dot.
        string description;
        uint256 timeStamp;
        bytes32 id;
    }
  
    mapping(bytes32 id => EmergencyReport emergencyReport) private s_EmergencyReports;
    mapping(bytes32 id => Information info) public s_Information;
    mapping(bytes32 id => address[]) private s_Voters;
    mapping(EmergencyType emergencyType => bytes32[] ids) public s_EmergencyTypeToIdArray;

    mapping(address => bool) private voted; 
    mapping(Information info => address[] heading) s_Heading;

    

    event EmergencyReportCreatedEvent(
        address creator,
        uint64 lat,
        uint64 len,
        EmergencyType emergencyType,
        uint8 urgencyRate,
        string description,
        uint256 timeStamp,
        bytes32 id
    );
    event EmergencyReportUpdatedEvent(
        uint64 lat,
        uint64 len,
        EmergencyType emergencyType,
        uint8 urgencyRate,
        string description,
        uint256 timeStamp
    );
    event EmergencyReportRemovedEvent(
        bytes32 id
    );
    event InformationCreatedEvent(
        address creator,
        uint64 lat,
        uint64 len,
        string description,
        uint256 timestamp,
        bytes32 id
    );
    event InformationUpdatedEvent(
        uint64 lat,
        uint64 len,
        string description,
        uint256 timeStamp
    );
    event InformationRemovedEvent(
        bytes32 id
    );

    event HeadingCallCreatedEvent(
        address creator,
        uint64 lat,
        uint64 len,
        string description,
        uint256 timestamp,
        bytes32 id
    );
    event HeadingCallUpdatedEvent(
        uint64 lat,
        uint64 len,
        string description,
        uint256 timestamp
    );
    event HeadingCallRemovedEvent(
        bytes32
    );
     event VotesCountedEvent(
        bytes32 id,
        uint256 approvalCount,
        uint256 disapprovalCount
    );


    function createEmergencyReport(EmergencyReportWithNoId memory _emergencyReportWithNoId) public {

        bytes32 id = keccak256(abi.encodePacked(
            msg.sender, 
            _emergencyReportWithNoId.lat, 
            _emergencyReportWithNoId.len, 
            _emergencyReportWithNoId.emergencyType, 
            _emergencyReportWithNoId.urgencyRate, 
            _emergencyReportWithNoId.description, 
            _emergencyReportWithNoId.timeStamp));
        
        s_EmergencyReports[id] = EmergencyReport({
        creator: msg.sender,
        lat: _emergencyReportWithNoId.lat,
        len: _emergencyReportWithNoId.len,
        emergencyType: _emergencyReportWithNoId.emergencyType,
        urgencyRate: _emergencyReportWithNoId.urgencyRate,
        description: _emergencyReportWithNoId.description,
        timeStamp: _emergencyReportWithNoId.timeStamp,
        id: id,
        approvalCount:0,
        disapprovalCount:0
        });    
        s_EmergencyTypeToIdArray[ _emergencyReportWithNoId.emergencyType].push(id);
        s_Voters[id].push(msg.sender);
        
        emit EmergencyReportCreatedEvent(
            msg.sender, 
            _emergencyReportWithNoId.lat, 
            _emergencyReportWithNoId.len, 
            _emergencyReportWithNoId.emergencyType, 
            _emergencyReportWithNoId.urgencyRate, 
            _emergencyReportWithNoId.description, 
            _emergencyReportWithNoId.timeStamp, 
            id);
    }    

       function voteForEmergency(address sender, bool approve, bytes32 id) public {
        // Ensure the report exists
        require(s_EmergencyReports[id].creator != address(0), "Emergency report does not exist");

        // Ensure the voter has not voted before
        require(voted[sender] == false,"Sender has already voted");

        // Mark the voter as voted
        voted[sender] = true;
        s_Voters[id].push(sender);

        // Update approval or disapproval count
        if (approve) {
            s_EmergencyReports[id].approvalCount++;
        } else {
            s_EmergencyReports[id].disapprovalCount++;
        }

    }
    function updateEmergencyReport(bytes32 id,EmergencyReportWithNoId memory _emergencyReportWithNoId) public {
        require(msg.sender == s_EmergencyReports[id].creator, "Only the creator update the emergency report");
       
        s_EmergencyReports[id].lat = _emergencyReportWithNoId.lat;
        s_EmergencyReports[id].len = _emergencyReportWithNoId.len;
        s_EmergencyReports[id].emergencyType = _emergencyReportWithNoId.emergencyType;
        s_EmergencyReports[id].urgencyRate = _emergencyReportWithNoId.urgencyRate;
        s_EmergencyReports[id].description = _emergencyReportWithNoId.description;
        s_EmergencyReports[id].timeStamp = _emergencyReportWithNoId.timeStamp;

        
        emit EmergencyReportUpdatedEvent(
        _emergencyReportWithNoId.lat,
        _emergencyReportWithNoId.len,
        _emergencyReportWithNoId.emergencyType,
        _emergencyReportWithNoId.urgencyRate,
        _emergencyReportWithNoId.description,
        _emergencyReportWithNoId.timeStamp
        );

    }
    function removeEmergencyReport(bytes32 id) public {
        require(s_EmergencyReports[id].id != 0, "Invalid id "); 
        s_EmergencyReports[id].id = 0;

        emit EmergencyReportRemovedEvent(id);
    }
      function createEmergencyCallBundle(EmergencyReportWithNoId[] memory _emergencyReportWithNoId) public {
        for(uint256 i = 0; i < _emergencyReportWithNoId.length; i++) {
            createEmergencyReport(_emergencyReportWithNoId[i]);
        }
    }

    function createInformation(Information memory _information) public {
         bytes32 id = keccak256(abi.encodePacked(
            msg.sender, 
            _information.lat, 
            _information.len, 
            _information.description, 
            _information.timeStamp));

        s_Information[id] = Information({
            creator: msg.sender,
            lat: _information.lat,
            len: _information.len,
            description: _information.description,
            timeStamp: _information.timeStamp,
            id: _information.id
        });
        s_Information[id].push(msg.sender);
        
        emit InformationCreatedEvent(
            msg.sender,
            _information.lat,
            _information.len,
            _information.description,
            _information.timeStamp,
            id);
    }
    function updateInformation(bytes32 id, Information memory information) public {
        require(s_Information[id].id != 0, "Invalid id");

        s_Information[id].lat = information.lat;
        s_Information[id].len = information.len;
        s_Information[id].description = information.description;
        s_Information[id].timeStamp = information.timeStamp;

        emit InformationUpdatedEvent(
            information.lat,
            information.len,
            information.description,
            information.timeStamp
        );
    }
    function removeInformation(bytes32 id) public {
        require(s_Information[id].id != 0,"Invalid id");
        s_Information[id].id = 0;

        emit InformationRemovedEvent(id);
    }
    function getIdArray(EmergencyType emergencyType) public view returns (bytes32[] memory ids) {
        require(s_EmergencyTypeToIdArray[emergencyType].length != 0, "There is no id with this type");
        return s_EmergencyTypeToIdArray[emergencyType];
    }

    function getEmergencyCallById(bytes32 id) public view returns (EmergencyReport memory) {
        return s_EmergencyReports[id];
    }  

    function encryptionProcessOfEmergencyReport(EmergencyReport memory _emergencyReport) public view returns (bytes32) {
    
        return keccak256(abi.encodePacked(
            msg.sender,
            _emergencyReport.lat,
            _emergencyReport.len,
            _emergencyReport.emergencyType,
            _emergencyReport.urgencyRate,
            _emergencyReport.description,
            _emergencyReport.timeStamp
        ));   
    }
    function encryptionProcessOfInformation(Information memory _information) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            msg.sender,
            _information.lat,
            _information.len,
            _information.description,
            _information.timeStamp
        ));
    } 
    
   
}