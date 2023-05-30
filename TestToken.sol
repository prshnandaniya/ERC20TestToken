// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToken is Ownable, ERC20 {
    address[] public poolLists;
    mapping(address => bool) private _isPoolEnabled;

    constructor(uint256 _totalSupply) ERC20("TestToken", "TT") {
        _mint(msg.sender, _totalSupply);
    }

    function isPool(address _contractAddress) external view returns (bool) {
        return _isPoolEnabled[_contractAddress];
    }

    function setPoolStatus(address _contractAddress, bool _status)
        external
        onlyOwner
    {
        _isPoolEnabled[_contractAddress] = _status;
    }

    function addPool(address _contractAddress) external onlyOwner {
        _isPoolEnabled[_contractAddress] = true;
        poolLists.push(_contractAddress);
    }

    function _isContract(address _address) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }

    function isContract(address _address) external view returns (bool) {
        return _isContract(_address);
    }

    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        bool isBuy = _isPoolEnabled[sender];
        bool isSell = _isPoolEnabled[recipient];

        if (isBuy) {
            require(
                !_isContract(recipient),
                "Receipient should not be contract address"
            );
        }

        if (isSell) {
            require(
                !_isContract(sender),
                "Sender should not be contract address"
            );
        }

        super._beforeTokenTransfer(sender, recipient, amount);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
