pragma solidity ^0.8.0;

/*
    Classified Access Control Smart Contract (Draft)

    This contract will manage:
    - User registration
    - Clearance assignment
    - Access verification
*/

contract ClassifiedAccessControl {

    enum ClearanceLevel { NONE, CONFIDENTIAL, SECRET, TOP_SECRET }

    struct User {
        address userAddress;
        ClearanceLevel clearance;
        bool isActive;
        bool exists;
    }

    // Create the priveledged user, admin, for creating clearances
    address public admin;

    // Modifier to check if user calling function is actually admin
    modifier onlyAdmin()
    {
        require(msg.sender == admin, "User is not admin");
        _; 
    }

    // Constructor to set admin of clearance registry
    // This happens at deployment
    constructor()
    {
        admin = msg.sender;
    }

    mapping(address => User) public registry;

    // events
    event userAdded(address indexed user, ClearanceLevel level);
    event clearanceUpdated(address indexed user, ClearanceLevel prevLevel, ClearanceLevel newLevel);
    event userDeactivated(address indexed user);
    event userReactivated(address indexed user);

    // contract functionality
    function addUser(address _user, ClearanceLevel _level) public onlyAdmin {
        // Make sure parameters are valid
        require(_user != address(0), "Invalid user address.");
        require(registry[_user].exists != true, "User can not be adder, already registered.");

        // Create new user
        registry[_user] = User({userAddress: _user, clearance: _level, isActive: true, exists: true});

        // Emit event
        emit userAdded(_user, _level);
    }

    function updateClearance(address _user, ClearanceLevel _level) public onlyAdmin {
        // Make sure parameters are valid
        require(_user != address(0), "Invalid user address.");
        require(registry[_user].exists != false, "User does not exist.");
        require(registry[_user].isActive != false, "User is not active.");

        // Change clearance
        ClearanceLevel prevLevel = registry[_user].clearance;
        registry[_user].clearance = _level;

        // Emit
        emit clearanceUpdated(_user, prevLevel, _level);
    }

    function deactivateUser(address _user) public onlyAdmin {
        // Make sure parameters are valid
        require(_user != address(0), "Invalid user address.");
        require(registry[_user].exists != false, "User does not exist.");
        require(registry[_user].isActive != false, "User is already not active.");

        registry[_user].isActive = false;

        emit userDeactivated(_user);
    }

    function verifyAccess(address _user, ClearanceLevel _requiredLevel) public view returns (bool) {
        User memory user = registry[_user];
        bool hasAccess = false;
        if (user.exists && user.isActive && user.clearance >= _requiredLevel)
        {
            hasAccess = true;
        }
        return hasAccess;
    }
}