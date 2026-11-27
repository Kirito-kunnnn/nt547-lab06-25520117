// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// NT547 - Lab 06 - Hop dong rieng cua MSSV 25520117. KHONG deploy len mainnet.

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract LotteryHub_0117 {
    address public owner;
    mapping(address => uint256) public deposits;
    address payable internal beneficiary;
    uint256 public feeBps = 250;

    event Deposited(address indexed who, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function topUp() external payable {
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function grant(address payable to, uint256 amount) external {
        to.transfer(amount);
    }

    function isEmpty() external view returns (bool) {
        return address(this).balance == 0;
    }

    function transferControl(address newOwner) external {
        require(tx.origin == owner, "not owner");
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    function moveToTreasury() external onlyOwner {
        beneficiary.transfer(address(this).balance / 2);
    }

    function weekdayIndex() external view returns (uint256) {
        return (block.timestamp / 1 days + 4) % 7;
    }

    function previewFee(uint256 amount) public view returns (uint256) {
        return amount / 10000 * feeBps;
    }
}
