# QuietSettle

QuietSettle is a confidential escrow desk for milestone work. It is meant for agencies, auditors, suppliers, DAO contributors, and RWA operators who need public settlement proof without exposing invoice values or negotiated rates.

## Product Thesis

Earlier Zama projects that stood out tended to share four traits:

- They used privacy for money, terms, identity, or compliance instead of treating encryption as a visual gimmick.
- They picked workflows people already understand: pay, sign, attest, settle, recover, or manage a wallet.
- They gave the frontend a real job instead of stopping at a contract demo.
- They made confidentiality useful to more than one party in the transaction.

QuietSettle combines those traits in a less crowded area: private milestone escrow for service procurement.

## User Flow

1. Buyer connects wallet.
2. Buyer creates a deal with a vendor, optional verifier, memo hash, and encrypted invoice amount.
3. Buyer funds the escrow with ETH on Sepolia.
4. Buyer approves when the deliverable is accepted.
5. Optional verifier approves completion or compliance.
6. Vendor calls release, or buyer releases directly.
7. Buyer can refund only before approval.
8. Authorized parties can request/decrypt the confidential amount through the Zama flow.

## What Is Production-Ready Here

- Branded frontend with logo, favicon, manifest, responsive layout, smooth scroll, reveal motion, and Zama-green accent `#abe338`.
- Wallet connection through an injected EIP-1193 wallet.
- Real contract transactions for `fund`, `approveByBuyer`, `approveByVerifier`, `release`, and `refund`.
- Real read path for `getDeal`.
- No fake transaction hashes or simulated success messages.
- Solidity escrow accounting per deal, with checks-effects-interactions and a local reentrancy guard.

## Zama Integration Boundary

Encrypted deal creation depends on the official Zama relayer SDK being loaded in the app runtime. The frontend intentionally blocks the create action until a relayer object is available.

Expected integration shape:

```ts
const input = zamaRelayer.createEncryptedInput(contractAddress, userAddress);
input.add64(BigInt(privateAmount));
const encrypted = await input.encrypt();

await contract.createDeal(
  vendor,
  verifier,
  encrypted.handles[0],
  encrypted.inputProof,
  memoHash
);
```

## Files

- `index.html`: production-style single-page dApp.
- `logo.svg`: app logo.
- `favicon.svg`: browser favicon.
- `manifest.webmanifest`: install metadata.
- `ConfidentialMilestoneEscrow.sol`: FHEVM escrow contract.
- `QuietSettle.md`: submission notes.
- `quietsettle-image-sections/index.html`: eight image references for the production interface direction.

## Deployment Plan

1. Install FHEVM Solidity dependencies.
2. Compile `ConfidentialMilestoneEscrow.sol` against the Zama Sepolia config.
3. Deploy to Sepolia.
4. Add the deployed address in the frontend.
5. Load the official Zama relayer SDK bootstrap.
6. Test create, fund, approve, release, refund, and status read with separate buyer/vendor/verifier wallets.

## Pitch

Vendor rates should not become public market data. QuietSettle lets a buyer prove that money is escrowed and approvals happened, while the commercial amount stays encrypted for the parties who need to know.
