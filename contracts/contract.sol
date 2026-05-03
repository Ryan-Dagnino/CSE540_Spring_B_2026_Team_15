// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract IAMContract {
    // Decentralized identifier (DID)
    // This struct has the owner, the hash off the DID, and whether this user exists
    struct DID {
        address owner;
        bytes32 didDocumentHash; 
        bool exists;
    }

    enum clearanceLevel
    {
        none,
        secret,
        top_secret
    }

    // Credential
    // This struct has the issuer, the hash off the credential, and whether this credential is revoked
    struct Credential {
        bytes32 credentialHash; // hash of off-chain credential
        address issuer; // Who issues the credential
        bool revoked; // Has it been revoked
        bytes32 did;
        clearanceLevel level; // What level of clearance is this credential
        uint256 expires; // When does this credential expire
    }

    // Storage
    address public dcsa;
    address public proposedDcsa;
    address public owner;

    // DID registry mapping, maps did hash to did
    mapping(bytes32 => DID) public didRegistry;

    // credential mapping, maps credential hash to credential
    mapping(bytes32 => Credential) public credentials;

    // Events
    event DIDRegistered(bytes32 indexed did, address indexed owner);
    event ClearanceIssued(bytes32 indexed credentialId, bytes32 indexed did, address indexed issuer, clearanceLevel level);
    event ClearanceRevoked(bytes32 indexed credentialId);
    event ClearanceVerified(bytes32 indexed credentialId, bool valid);
    event DCSAProposed(address indexed proposedDCSA);

    // Modifiers
    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _;
    }

    modifier onlyDCSA() {
        require(msg.sender == dcsa, "Only DCSA authorized");
        _;
    }

    // Constructor to set DCSA address
    constructor(address _dcsa) {
        require(_dcsa != address(0), "Invalid DCSA address");
        dcsa = _dcsa;
        owner = msg.sender;
    }


    // Register a new DID
    function registerDID(bytes32 did, bytes32 didDocumentHash) external {
        require(!didRegistry[did].exists, "DID already exists");

        DID memory newDid = DID({owner: msg.sender, didDocumentHash: didDocumentHash, exists: true});
        didRegistry[did] = newDid;

        emit DIDRegistered(did, msg.sender);
    }

    // Issue a new credential for a DID
    function issueClearance(bytes32 credentialId, bytes32 did, bytes32 credentialHash, clearanceLevel _level, uint256 clearanceDuration) external onlyDCSA {
        require(didRegistry[did].exists, "Unknown DID");
        require(credentials[credentialId].issuer == address(0), "Credential already exists");

        Credential memory newCredential = Credential({credentialHash: credentialHash, issuer: msg.sender, revoked: false, did: did, level: _level, expires: block.timestamp + clearanceDuration});
        credentials[credentialId] = newCredential;

        emit ClearanceIssued(credentialId, did, msg.sender, _level);
    }



    // Revoke an issued credential
    function revokeClearance(bytes32 credentialId) external onlyDCSA {
        Credential storage cred = credentials[credentialId];

        require(cred.issuer == msg.sender, "Not clearance issuer");
        require(!cred.revoked, "Already revoked");

        cred.revoked = true;
        emit ClearanceRevoked(credentialId);
    }  


    // Verify credential validity
    function verifyClearance(bytes32 credentialId, clearanceLevel required) external returns (bool valid) {
        Credential memory cred = credentials[credentialId];

        valid = (cred.issuer == dcsa && !cred.revoked && cred.level >= required && cred.expires > block.timestamp);
        emit ClearanceVerified(credentialId, valid);

        return valid;
    }

    // These two functions propose a new DCSA and the proposed DCSA must accept. This removes
    // issues where the DCSA may be compromised, so the owner of the blockchain can elect a new DCSA
    // and that new DCSA must accept
    function proposeNewDcsa(address newDcsa) external onlyOwner
    {
        require(newDcsa != address(0), "Invalid Address");
        proposedDcsa = newDcsa;
        emit DCSAProposed(newDcsa);
    }

    function acceptDCSA() external
    {
        require(msg.sender == proposedDcsa, "Not the proposed DCSA");
        dcsa = proposedDcsa;
    }

}