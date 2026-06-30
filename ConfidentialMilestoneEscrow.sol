// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Install with: npm install @fhevm/solidity
// Target: Zama FHEVM on Sepolia.
import { FHE, euint64, externalEuint64 } from "@fhevm/solidity/lib/FHE.sol";
import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract ConfidentialMilestoneEscrow is SepoliaConfig {
    bool private locked;

    struct Deal {
        address buyer;
        address vendor;
        euint64 encryptedAmount;
        bool buyerApproved;
        bool verifierApproved;
        bytes32 memoHash;
        uint256 deposit;
        bool funded;
        bool released;
    }

    uint256 public nextDealId;
    mapping(uint256 => Deal) private deals;
    mapping(uint256 => address) public verifierOf;

    event DealCreated(uint256 indexed dealId, address indexed buyer, address indexed vendor, bytes32 memoHash);
    event DealFunded(uint256 indexed dealId, uint256 visibleDeposit);
    event BuyerApproved(uint256 indexed dealId);
    event VerifierApproved(uint256 indexed dealId, address indexed verifier);
    event Released(uint256 indexed dealId, address indexed vendor);
    event Refunded(uint256 indexed dealId, address indexed buyer);

    modifier onlyBuyer(uint256 dealId) {
        require(msg.sender == deals[dealId].buyer, "Only buyer");
        _;
    }

    modifier onlyVerifier(uint256 dealId) {
        require(msg.sender == verifierOf[dealId], "Only verifier");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function createDeal(
        address vendor,
        address verifier,
        externalEuint64 encryptedAmount,
        bytes calldata inputProof,
        bytes32 memoHash
    ) external returns (uint256 dealId) {
        require(vendor != address(0), "Vendor required");

        dealId = nextDealId++;
        euint64 amount = FHE.fromExternal(encryptedAmount, inputProof);

        deals[dealId] = Deal({
            buyer: msg.sender,
            vendor: vendor,
            encryptedAmount: amount,
            buyerApproved: false,
            verifierApproved: verifier == address(0),
            memoHash: memoHash,
            deposit: 0,
            funded: false,
            released: false
        });

        verifierOf[dealId] = verifier;

        FHE.allowThis(amount);
        FHE.allow(amount, msg.sender);
        FHE.allow(amount, vendor);
        if (verifier != address(0)) {
            FHE.allow(amount, verifier);
        }

        emit DealCreated(dealId, msg.sender, vendor, memoHash);
    }

    function fund(uint256 dealId) external payable onlyBuyer(dealId) {
        require(!deals[dealId].funded, "Already funded");
        require(msg.value > 0, "Deposit required");
        deals[dealId].deposit = msg.value;
        deals[dealId].funded = true;
        emit DealFunded(dealId, msg.value);
    }

    function approveByBuyer(uint256 dealId) external onlyBuyer(dealId) {
        deals[dealId].buyerApproved = true;
        emit BuyerApproved(dealId);
    }

    function approveByVerifier(uint256 dealId) external onlyVerifier(dealId) {
        deals[dealId].verifierApproved = true;
        emit VerifierApproved(dealId, msg.sender);
    }

    function release(uint256 dealId) external nonReentrant {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.buyer || msg.sender == deal.vendor, "Not a party");
        require(deal.funded, "Not funded");
        require(!deal.released, "Released");

        require(deal.buyerApproved && deal.verifierApproved, "Approval missing");

        uint256 payment = deal.deposit;
        deal.released = true;
        deal.deposit = 0;

        (bool sent, ) = payable(deal.vendor).call{ value: payment }("");
        require(sent, "Transfer failed");
        emit Released(dealId, deal.vendor);
    }

    function refund(uint256 dealId) external onlyBuyer(dealId) nonReentrant {
        Deal storage deal = deals[dealId];
        require(deal.funded, "Not funded");
        require(!deal.released, "Released");
        require(!deal.buyerApproved, "Already approved");

        uint256 payment = deal.deposit;
        deal.released = true;
        deal.deposit = 0;

        (bool sent, ) = payable(deal.buyer).call{ value: payment }("");
        require(sent, "Transfer failed");
        emit Refunded(dealId, deal.buyer);
    }

    function getEncryptedAmount(uint256 dealId) external view returns (euint64) {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.buyer || msg.sender == deal.vendor || msg.sender == verifierOf[dealId], "No access");
        return deal.encryptedAmount;
    }

    function getDeal(uint256 dealId)
        external
        view
        returns (
            address buyer,
            address vendor,
            address verifier,
            bytes32 memoHash,
            uint256 deposit,
            bool funded,
            bool buyerApproved,
            bool verifierApproved,
            bool released
        )
    {
        Deal storage deal = deals[dealId];
        return (
            deal.buyer,
            deal.vendor,
            verifierOf[dealId],
            deal.memoHash,
            deal.deposit,
            deal.funded,
            deal.buyerApproved,
            deal.verifierApproved,
            deal.released
        );
    }
}
