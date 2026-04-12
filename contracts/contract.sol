// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
    Decentralized Identity and Access Management

    - Users self-register DIDs
    - Issuers (DCSA) issue verifiable credentials
    - Verifiers (DCSA) check credential status
    - Only hashes are stored on-chain (no PII)
*/

contract DecentralizedIAMContract {
    // Decentralized Identifier (DID)
    struct DID {
        address owner;
        bytes32 didDocumentHash; // hash of off-chain DID document
        bool exists;
    }

    // Verifiable Credential for status only data off-chain)
    struct Credential {
        bytes32 credentialHash; // hash of off-chain credential
        address issuer;
        bool revoked;
    }

    // Storage

    address public dcsa;
    // DID identifier (hash) → DID
    mapping(bytes32 => DID) public didRegistry;

    // Credential ID → Credential record
    mapping(bytes32 => Credential) public credentials;

    // Events
    event DIDRegistered(bytes32 indexed did, address indexed owner);
    event ClearanceIssued(
        bytes32 indexed credentialId,
        bytes32 indexed did,
        address indexed issuer
    );

    event ClearanceRevoked(bytes32 indexed credentialId);

    event ClearanceVerified(bytes32 indexed credentialId, bool valid);

    // Modifiers
    modifier onlyOwner(bytes32 did) {
        require(didRegistry[did].exists, "DID not registered");
        require(didRegistry[did].owner == msg.sender, "Not DID owner");
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
    }


    // Register a new DID
    function registerDID(bytes32 did, bytes32 didDocumentHash) external {
        require(!didRegistry[did].exists, "DID already exists");

        didRegistry[did] = DID({
            owner: msg.sender,
            didDocumentHash: didDocumentHash,
            exists: true
        });

        emit DIDRegistered(did, msg.sender);
    }

    // Issue a new credential for a DID
    function issueClearance(
        bytes32 credentialId,
        bytes32 did,
        bytes32 credentialHash
    ) external onlyDCSA {
        require(didRegistry[did].exists, "Unknown DID");
        require(credentials[credentialId].issuer == address(0), "Credential already exists");

        credentials[credentialId] = Credential({
            credentialHash: credentialHash,
            issuer: msg.sender,
            revoked: false
        });

        emit ClearanceIssued(credentialId, did, msg.sender);
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
    function verifyClearance(bytes32 credentialId) external returns (bool valid) {
        Credential memory cred = credentials[credentialId];

        valid = (cred.issuer == dcsa && !cred.revoked);
        emit ClearanceVerified(credentialId, valid);

        return valid;
    }

}