# QuietSettle Demo Video Script

Target length: 3 minutes

## 0:00-0:20 - Opening

Show the QuietSettle hero at `https://quietsettle.vercel.app`.

Voiceover:
"QuietSettle is a confidential milestone escrow app for agencies, auditors, DAO service providers, suppliers, and RWA operators. It uses Zama FHEVM so deal values can stay encrypted while funding, approvals, release, and refund state remain auditable on Sepolia."

## 0:20-0:45 - Problem

Scroll to the proof section.

Voiceover:
"Escrow workflows usually leak commercial terms. Invoice size, milestone value, and vendor economics become public metadata. QuietSettle separates what must be public from what should remain confidential: parties, memo hashes, and approval state are visible; milestone amounts are stored as encrypted handles."

## 0:45-1:15 - Registry

Scroll to Deal Registry. Search for a deal and select one row.

Voiceover:
"The registry gives operators a searchable view of escrow deals. This is intentionally labeled as a workspace cache. When a contract address is configured, the selected deal can be refreshed from the Sepolia escrow contract, so the interface does not pretend local data is a live chain index."

## 1:15-1:45 - Workspace

Show selected workspace and approval rail.

Voiceover:
"Inside the workspace, the buyer, vendor, verifier, memo hash, deposit, and encrypted amount handle sit beside the approval rail. The workflow is simple: create the deal, fund the escrow, collect buyer approval, collect verifier approval if required, then release funds to the vendor."

## 1:45-2:15 - Create And Settle

Scroll to Create, then Settlement Controls.

Voiceover:
"To create a deal, the frontend validates addresses and memo input, then requires the Zama relayer encryption path before sending `createDeal`. Settlement actions are real wallet actions: fund escrow, buyer approve, verifier approve, release vendor payment, or refund before approval. Each button calls the configured smart contract."

## 2:15-2:40 - Decryption

Scroll to User Decryption and click Sign Decrypt Request if a wallet is connected.

Voiceover:
"When an authorized party needs to view the confidential amount, QuietSettle uses an EIP-712 signing flow. The wallet signs a typed request for the selected encrypted handle, and that signature is used with the Zama user-decryption flow."

## 2:40-3:00 - Developer Close

Scroll to Developer Reference.

Voiceover:
"QuietSettle ships with the frontend, a Zama FHEVM escrow contract, documentation, and copy-ready integration snippets. It is designed as a production-grade confidential finance workflow: private values, public settlement state, and real contract actions on Sepolia."

On-screen close:
"QuietSettle - confidential milestone escrow for Zama FHEVM"
