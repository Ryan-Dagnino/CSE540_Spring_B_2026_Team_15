# Identity & Access Management (IAM) for Classified Systems
### CSE540 Blockchain | Team 15 | Arizona State University (Spring 2026)

This repository implements a **Decentralized Identity (DID)** and **Classified Access Control** system. It provides a secure, immutable registry for managing personnel clearances (Secret, Top Secret, etc.) using blockchain technology to ensure sensitive authorization data is verifiable and tamper-proof.

The project utilizes Ethereum's blockchain (GoQuorum) for private, permissioned functionality.

---

## The Role of the DCSA

The **Defense Counterintelligence and Security Agency (DCSA)** acts as the central administrative authority within the smart contract. 

### Administrative Powers
* **Issuance:** Only the DCSA can call `issueClearance` to grant a clearance level to a user.
* **Revocation:** The DCSA has the exclusive right to call `revokeClearance` to immediately invalidate a credential.
* **Verification:** The `verifyClearance` function ensures that a credential was signed by the current, active DCSA address.

### DCSA Succession (Governance)
To protect against compromised accounts, the contract owner can propose a change in authority:
1. **Proposal:** `proposeNewDcsa(address newDcsa)` is called by the owner.
2. **Acceptance:** The new address must call `acceptDCSA()` to officially take over the role.

---

## Deployment Instructions (Remix IDE)

Currently, the contract is deployed and tested using the **Remix Online IDE**. 

### 1. Setup & Compilation
1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create `IAMContract.sol` in the `contracts` folder and paste the source code.
3. In the **Solidity Compiler** tab, select version `0.8.19` and click **Compile**.

### 2. Deployment (Critical Step)
In the **Deploy & Run Transactions** tab:
1. **Environment:** Select "Remix VM (Cancun)" for local testing.
2. **DCSA Address Initialization:** * Before clicking deploy, look at the **Deploy** button area. 
   * There is an input field for the `_dcsa` address. 
   * Copy an address from the **Account** dropdown at the top of the tab and paste it into this field.
   * **Note:** This address will be the only one authorized to issue clearances once the contract is live.
3. Click **Deploy**.

---

## Contract Parameters & Enums

### Clearance Levels (`enum`)
When interacting with `issueClearance` or `verifyClearance`, use these integer values:
* `0`: None
* `1`: Secret
* `2`: Top Secret

### Required Inputs
* **DID / Credential ID:** Use a unique `bytes32` hex string (e.g., `0x123...`).
* **Duration:** Expiry time for clearances is calculated in seconds added to the current time.

---

## File Hierarchy
```text
.
├── contracts/
│   └── contract.sol      # Main IAM Smart Contract logic
├── README.md             # Project documentation
└── (Future Work)         # Frontend (ABI JSON) and Test folders
