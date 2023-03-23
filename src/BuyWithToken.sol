// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/// @title Buy with Token
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

    struct Market {
        address assetAddress;
        uint256 assetID;
        uint256 price;
        string currency;
        address seller;
    }

    /// @dev This maps the token address to the aggregator's address
    uint256 itemID;
    mapping (string => address) private aggregrator;
    mapping (string => Token) private tokenDetails;
    mapping (uint256 => Market) private listedAsset;

    constructor(){
        addTokenDetails(
            "Ethereum","ETH",18,
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );
        addTokenDetails(
            "Tether USD","USDT",8,
            0x3E7d1eAB13ad0104d2750B8863b489D65364e32D,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        );
    }

    // function placeBid(address _nftContractAddress, uint256 _nftTokenID) public payable {
    //     NFTAuction storage bidNFT = nftAuctionDetails[_nftContractAddress][_nftTokenID];
    //     require(bidNFT.nftOwner != address(0), "This NFT is not for auction");
    //     require(bidNFT.auctionEndTime > block.timestamp, "The auction has ended");
    //     bidNFT.bidders.push(payable(msg.sender));
    //     Bid storage myBid = bidInformation[_nftContractAddress][_nftTokenID][msg.sender];
    //     nftBidders[_nftContractAddress][_nftTokenID].push(msg.sender);
    //     myBid.bidder = payable(msg.sender);
    //     myBid.bid += msg.value;
    //     emit BidforNFT(msg.sender);
    // }

    function listAsset(address _assetAddress, uint256 _assetID, uint256 _price) public {
        itemID++;
        Market storage listNFT = listedAsset[itemID];
        listNFT.assetAddress = _assetAddress;
        listNFT.assetID = _assetID;
        listNFT.price = _price;
        listNFT.currency = "ETH";
        listNFT.seller = msg.sender;
        IERC721(_assetAddress).transferFrom(msg.sender, address(this),_assetID);
    }

    function listAsset(address _assetAddress, uint256 _assetID, uint256 _price, string calldata _symbol) public {
        itemID++;
        Market storage listNFT = listedAsset[itemID];
        listNFT.assetAddress = _assetAddress;
        listNFT.assetID = _assetID;
        listNFT.price = _price;
        listNFT.currency = _symbol;
        listNFT.seller = msg.sender;
        IERC721(_assetAddress).transferFrom(msg.sender, address(this),_assetID);
    }

    function buyAssetWithToken(uint256 itemMarketID) public {
        Market memory item = listedAsset[itemMarketID];
        IERC20(tokenDetails["USDT"].contractAddress).transferFrom(msg.sender,item.seller,uint256(getSwapTokenPrice(item.currency,"USDT",int256(item.price))));
    }
    function buyAssetWithToken(uint256 itemMarketID, string memory _token) public {
        Market memory item = listedAsset[itemMarketID];
        IERC20(tokenDetails["USDT"].contractAddress).transferFrom(msg.sender,item.seller,uint256(getSwapTokenPrice(item.currency,_token,int256(item.price))));
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
        string memory _from,
        string memory _to,
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
        fromPrice = scalePrice(fromPrice , fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(tokenDetails[_to].aggregratorAddress)
            .latestRoundData();
        uint8 toDecimals = AggregatorV3Interface(tokenDetails[_to].aggregratorAddress).decimals();
        toPrice = scalePrice(toPrice, toDecimals, _decimals);

        return (fromPrice * decimals) / toPrice;
    }
    function getDerivedPriceBase(
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

    function factorPrice(
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
        string memory _fromToken, 
        string memory _toToken,
        // uint8 _decimals,
        int256 _amount
    ) public view returns (int256) {
        return _amount * getDerivedPrice(
            _fromToken,
             _toToken,
            tokenDetails[_toToken].decimal);
    }
}