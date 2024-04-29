
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";

contract Crowdsale {
    address public owner;
    MyToken public token;
    uint256 public rate;
    uint256 public startTime;
    uint256 public endTime;
    bool public saleActive;
    mapping(address => uint256) public contributions;

    uint256 public cliffPeriod; // In seconds
    uint256 public vestingPeriod; // In seconds

    struct VestingSchedule {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => VestingSchedule[]) public vestingSchedules;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 value);
    event SaleStarted(uint256 startTime);
    event SaleEnded(uint256 endTime);
    event SaleHalted();
    event VestingScheduled(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier duringSale() {
        require(saleActive, "Crowdsale is not active");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Crowdsale is not active");
        _;
    }

    constructor(
        address _token,
        uint256 _rate,
        uint256 _startDelayInDays,
        uint256 _durationInDays,
        uint256 _cliffPeriod,
        uint256 _vestingPeriod
    ) {
        owner = msg.sender;
        token = MyToken(_token);
        rate = _rate;
        startTime = block.timestamp + (_startDelayInDays * 86400); //ONE_DAY_IN_SECONDS
        endTime = startTime + (_durationInDays * 86400); //ONE_DAY_IN_SECONDS
        saleActive = false;
        cliffPeriod = _cliffPeriod * 86400;
        vestingPeriod = _vestingPeriod * 86400;
    }

    function startSale() external onlyOwner {
        require(!saleActive, "Sale is already active");
        saleActive = true;
        emit SaleStarted(startTime);
    }

    function endSale() external onlyOwner {
        require(saleActive, "Sale is not active");
        saleActive = false;
        emit SaleEnded(endTime);
    }

    function haltSale() external onlyOwner {
        require(saleActive, "Sale is not active");
        saleActive = false;
        emit SaleHalted();
    }

    function buyTokens() external payable duringSale {
        uint256 amount = msg.value * rate;
        require(amount > 0, "Invalid amount");

        contributions[msg.sender] += msg.value;
        token.transfer(msg.sender, amount);
        emit TokensPurchased(msg.sender, amount, msg.value);
    }

    function scheduleVesting(address _beneficiary, uint256 _amount) external onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_amount > 0, "Invalid amount");

        vestingSchedules[_beneficiary].push(VestingSchedule({
            amount: _amount,
            startTime: block.timestamp
        }));

        emit VestingScheduled(_beneficiary, _amount);
    }

    function releaseVestedTokens(address _beneficiary) external {
        require(_beneficiary != address(0), "Invalid beneficiary address");

        VestingSchedule[] storage schedules = vestingSchedules[_beneficiary];
        for (uint256 i = 0; i < schedules.length; i++) {
            VestingSchedule storage schedule = schedules[i];
            uint256 vestedAmount = calculateVestedAmount(schedule.amount, schedule.startTime);
            if (vestedAmount > 0) {
                token.transfer(_beneficiary, vestedAmount);
                schedule.amount -= vestedAmount;
            }
        }
    }

    function calculateVestedAmount(uint256 _totalAmount, uint256 _startTime) internal view returns (uint256) {
        if (block.timestamp < _startTime + cliffPeriod) {
            return 0;
        } else if (block.timestamp >= _startTime + vestingPeriod) {
            return _totalAmount;
        } else {
            return _totalAmount * (block.timestamp - _startTime) / vestingPeriod;
        }
    }
}
