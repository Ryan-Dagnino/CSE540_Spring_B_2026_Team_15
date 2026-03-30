# CSE540_Spring_B_2026_Team_15
This repository is for the CSE540 Blockchain class at ASU during the Spring 2026 semester for team 15.

Our team has chosen the identity management option and we have chosen to do a classified access control project. This entails having a smart contract for uploading new individuals onto the registry, updated their classified status (i.e. secret, top secret, etc), and suspending/removing individuals.

This project will be using Ethereum's blockchain using GoQuorum for private blockchain functionality.

-------- Setup Instructions --------
git clone https://github.com/Ryan-Dagnino/CSE540_Spring_B_2026_Team_15.git
cd CSE540_Spring_B_2026_Team_15
npm install

-------- Deployment --------
To use this system, you can send a transaction to the smart contract on the ethereum blockchain using the Application Binary Interface (ABI) JSON to communicate with the ethers.js frontend (This has yet to be implemented). The backend is solidity code and will be uploaded to GoQuorum instead of the public Ethereum blockchain.

-------- Example --------
Connect to GoQuorum node
contract = new ethers.Contract(contractAddr, ABI, signer)
contract.AddToRegistry(user, classificationLevel)

-------- File Heirarchy --------
Within the top level of the repository, we will have a folder for contracts (which will only include a single contract), a frontend folder for the ABI JSON and other components related to that, and possibly a test folder for testing purposes.
