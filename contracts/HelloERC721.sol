// SPDX-License-Identifier: MIT
// (c)2024 Atlas (atlas@vialabs.io)
pragma solidity =0.8.17;

import "@vialabs-io/contracts/message/MessageClient.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract HelloERC721 is ERC721, MessageClient {
    using Strings for uint256;

    uint public nextNftId;

    constructor() ERC721("Hello ERC721!", "H721") {
        nextNftId = block.chainid * 10**4;
    }

    function mint() external {
        _mint(msg.sender, nextNftId);
        nextNftId++;
    }

    function bridge(uint _destChainId, address _recipient, uint _nftId) external onlyActiveChain(_destChainId) {
        require(ownerOf(_nftId) == msg.sender, "HelloERC721: caller is not the owner of the nft");

        // burn nft
        _burn(_nftId);

        // send cross chain message
        _sendMessage(_destChainId, abi.encode(_recipient, _nftId));
    }

    function messageProcess(uint, uint _sourceChainId, address _sender, address, uint, bytes calldata _data) external override  onlySelf(_sender, _sourceChainId)  {
        // decode message
        (address _recipient, uint _nftId) = abi.decode(_data, (address, uint));

        // mint tokens
        _mint(_recipient, _nftId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked('data:application/json;base64,', 
            Base64.encode(bytes(abi.encodePacked(
                '{"name":"VIA Labs Hello ERC721 #', tokenId.toString(), '", "description":"Hello ERC721 cross chain NFT example. https://github.com/VIALabs-io/hello-erc721", "image":"https://i.postimg.cc/FKkpPByb/cl-logo.png"}')
            )))
        );
    }
}