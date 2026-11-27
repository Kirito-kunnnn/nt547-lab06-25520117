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
    event ControlTransferred(address indexed oldOwner, address indexed newOwner);
    event Withdrawn(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        beneficiary = payable(msg.sender);
    }

    function topUp() external payable {
        require(msg.value > 0, "zero value");
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0 && amount <= address(this).balance, "invalid amount");
        emit Withdrawn(owner, amount);
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function grant(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "zero address");
        require(amount > 0 && amount <= address(this).balance, "invalid amount");
        emit Withdrawn(to, amount);
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "grant failed");
    }

    function isEmpty() external view returns (bool) {
        return address(this).balance <= 0;
    }

    function transferControl(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero");
        address oldOwner = owner;
        owner = newOwner;
        emit ControlTransferred(oldOwner, newOwner);
    }

    function moveToTreasury() external onlyOwner {
        address payable target = beneficiary != address(0) ? beneficiary : payable(owner);
        uint256 amount = address(this).balance / 2;
        require(amount > 0, "zero amount");
        (bool ok, ) = target.call{value: amount}("");
        require(ok, "treasury transfer failed");
    }

    function weekdayIndex() external view returns (uint256) {
        return block.timestamp / 1 days;
    }

    function previewFee(uint256 amount) public view returns (uint256) {
        return (amount * feeBps) / 10000;
    }
}
