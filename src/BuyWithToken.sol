// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Price Feed
/// @author Musa AbdulKareem (@WiseMrMusa)
/// @notice This gets the exchange rate of two Tokens

contract BuyWithToken is Ownable {

    struct Token {
        string name;
        string symbol;
        uint8 decimal;
        address aggregratorAddress;
        address contractAddress;
    }

    /// @dev This maps the token address to the aggregator's address
    mapping (string => address) private aggregrator;
    mapping (string => Token) private tokenDetails;

    constructor(){
        addTokenDetails(
            "Ethereum","ETH",18,
            0xAc559F25B1619171CbC396a50854A3240b6A4e99,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );
        addTokenDetails(
            "Tether USD","USDT",8,
            0x3E7d1eAB13ad0104d2750B8863b489D65364e32D,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        );
    }

    // function addAggregator(string calldata _tokenName, address _aggregatorAddress) external onlyOwner() {
    //     require(aggregrator[_tokenName] == address(0),"Aggregator Address already exist!");
    //     aggregrator[_tokenName] = _aggregatorAddress;
    // }

    function addTokenDetails(string memory _tokenName,string memory _tokenSymbol, uint8 _tokenDecimal, address _tokenAggregatorAddress, address _tokenContractAddress) public onlyOwner(){
        Token storage token = tokenDetails[_tokenSymbol];
        if (token.aggregratorAddress != address(0)) revert("Token Aggregator already exist");
        token.name = _tokenName;
        token.symbol = _tokenSymbol;
        token.decimal = _tokenDecimal;
        token.aggregratorAddress = _tokenAggregatorAddress;
        token.contractAddress = _tokenContractAddress;
    }


    // function deleteAggregator(string calldata _tokenName) external onlyOwner() {
    //     require(aggregrator[_tokenName] != address(0),"Aggregator Address does not exist");
    //     aggregrator[_tokenName] = address(0);
    // }

    function deleteTokenDetails(string calldata _tokenSymbol) external onlyOwner(){
        Token storage token = tokenDetails[_tokenSymbol];
        if (token.aggregratorAddress == address(0)) revert("Token Aggregator does not exist");
        token.name = "";
        token.symbol = "";
        token.decimal = 0;
        token.aggregratorAddress = address(0);
        token.contractAddress = address(0);
    }

    /// This gets the exchange rate of two tokens
    /// @param _from This is the token you're swapping from
    /// @param _to This is the token you are swapping to
    /// @param _decimals This is the decimal of the token you are swapping to
    function getDerivedPrice(
        string calldata _from,
        string calldata _to,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 fromPrice, , , ) = AggregatorV3Interface(tokenDetails[_from].aggregratorAddress)
            .latestRoundData();
        uint8 fromDecimals = AggregatorV3Interface(tokenDetails[_from].aggregratorAddress).decimals();
        fromPrice = scalePrice(fromPrice, fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(tokenDetails[_to].aggregratorAddress)
            .latestRoundData();
        uint8 toDecimals = AggregatorV3Interface(tokenDetails[_to].aggregratorAddress).decimals();
        toPrice = scalePrice(toPrice, toDecimals, _decimals);

        return (fromPrice * decimals) / toPrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

    function getSwapTokenPrice(
        string calldata _fromToken, 
        string calldata _toToken,
        // uint8 _decimals,
        int256 _amount
    ) external view returns (int256) {
        return _amount * getDerivedPrice(
            _fromToken,
             _toToken,
            tokenDetails[_toToken].decimal);
    }
}