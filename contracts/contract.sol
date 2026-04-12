// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
    Decentralized Identity and Access Management

    - Users self-register DIDs
    - Issuers issue verifiable credentials
    - Verifiers check credential status
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
    // DID identifier (hash) → DID
    mapping(bytes32 => DID) public didRegistry;

    // Credential ID → Credential record
    mapping(bytes32 => Credential) public credentials;

    // Events
    event DIDRegistered(bytes32 indexed did, address indexed owner);
    event CredentialIssued(
        bytes32 indexed credentialId,
        bytes32 indexed did,
        address indexed issuer
    );
    event CredentialRevoked(bytes32 indexed credentialId);
    event CredentialVerified(bytes32 indexed credentialId, bool valid);

    // Modifiers
    modifier onlyOwner(bytes32 did) {
        require(didRegistry[did].exists, "DID not registered");
        require(didRegistry[did].owner == msg.sender, "Not DID owner");
        _;
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
    function issueCredential(
        bytes32 credentialId,
        bytes32 did,
        bytes32 credentialHash
    ) external {
        require(didRegistry[did].exists, "Unknown DID");
        require(credentials[credentialId].issuer == address(0), "Already issued");

        credentials[credentialId] = Credential({
            credentialHash: credentialHash,
            issuer: msg.sender,
            revoked: false
        });

        emit CredentialIssued(credentialId, did, msg.sender);
    }

    // Revoke an issued credential
    function revokeCredential(bytes32 credentialId) external {
        Credential storage cred = credentials[credentialId];
        require(cred.issuer == msg.sender, "Only issuer can revoke");
        require(!cred.revoked, "Already revoked");

        cred.revoked = true;
        emit CredentialRevoked(credentialId);
    }

    // Verify credential validity
    function verifyCredential(bytes32 credentialId) external returns (bool valid) {
        Credential memory cred = credentials[credentialId];

        valid = (cred.issuer != address(0) && !cred.revoked);
        emit CredentialVerified(credentialId, valid);
        return valid;
    }
}