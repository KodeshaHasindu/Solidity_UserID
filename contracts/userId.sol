// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//IMPORT THE HARDHAT CONSOLE
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract UserId{
    address[] public userList;



    struct DOB {
        uint year;
        uint month;
        uint day;
    }
    

    struct Id{
        string fname;
        string lname; 
        DOB dob;
        string country;
        bool isVerified;
        uint256 createTime; 
        uint index;
        bool ageVerified;
    }

    mapping(address => Id) public UserStruct;
    mapping (address => bool) public whitelistClaimed;

    //events
    event idCreated(uint amount, address indexed userList);
    event AgeVerified(bool verified);

    bytes32 public markleRoot =0x8ae4777407987470bb4c7cde049e112c915237cb4c3c248b605355ddbac307a3;

     function whitelistMint(bytes32[] memory _merkaleProof) public {
        require(!whitelistClaimed[msg.sender], "Address already claimed");

        bytes32 leaf = keccak256(abi.encode(msg.sender));

        require(
            MerkleProof.verify(_merkaleProof, markleRoot, leaf), 
        "Invalid Merkle Proof."
        );

        whitelistClaimed[msg.sender] = true;
    }


    //function to verify that the user is exist or not (verficaion)
    function isVerified(address userAddress) public view returns(bool isIndeed) {
        if(userList.length == 0){
            return false;
        }

        return (userList[UserStruct[userAddress].index] == userAddress);
    }

    //function to verify the location
    function locationVerified(address userAddress, string memory country) public view returns (bool success) {
        require(isVerified(userAddress), "User does not exist or is not verified");
        // // Use keccak256 for string comparison
        //string memory userCountry = UserStruct[userAddress].country;
        // require(userCountry == country, "Location is not verified");
        // require(keccak256(bytes(UserStruct[userAddress].country)) == keccak256(bytes(country)), "Location is not verified");
        require(keccak256(abi.encodePacked(UserStruct[userAddress].country)) == keccak256(abi.encodePacked(country)));
        return true;
    }

    //function to create the userId
    function createUserId(address userAddress, string memory fname, string memory lname, uint256 year, uint256 month, uint day, string memory country ) public returns (bool success) {
        // if(isVerified(userAddress)){
        //     revert();
        //     // return false;
        // }

        require(!isVerified(userAddress), "User already exists and is verified");


        UserStruct[userAddress].fname = fname;
        UserStruct[userAddress].lname = lname;
        
        UserStruct[userAddress].dob = DOB(year, month, day);
        UserStruct[userAddress].country = country;
        UserStruct[userAddress].isVerified = true;

        userList.push(userAddress);

        UserStruct[userAddress].index = userList.length - 1;

        UserStruct[userAddress].createTime = block.timestamp;

        return true;
    }

   function verifyAgeLimit(address userAddress, uint ageLimit) public returns (bool verify) {
    require(isVerified(userAddress), "User not allowed");

    uint currentYear = (block.timestamp / 31557600 ) + 1970;
    uint age = currentYear - UserStruct[userAddress].dob.year;

    require(age >= ageLimit, "Under 18");

    // Emit AgeVerified event
    emit AgeVerified(true);

    // Set ageVerified to true
    UserStruct[userAddress].ageVerified = true;

    // Return the result
    return true;
}


     



    }