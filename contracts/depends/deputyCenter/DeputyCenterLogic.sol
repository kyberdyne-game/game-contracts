// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DeputyCenterLayout.sol";
import "../ownable/OwnableLogic.sol";
import "../nameServiceRef/NameServiceRefLogic.sol";
import "./DeputyCenterInterface.sol";

import "../helperLibrary/BytesLibrary.sol";

//the deputy center records all unique nonce if used
contract DeputyCenterLogic is DeputyCenterLayout, OwnableLogic, NameServiceRefLogic, DeputyCenterInterface {

    //    receive() payable external {
    //        process();
    //    }
    //
    //    fallback() payable external {
    //        process();
    //    }

    //if parse success:
    //  return designatedSender as msgSender,
    //  return signer as signer (never be address(0))
    //if parse fails:
    //  return address(0) as msgSender,
    //  return address(0) as signer
    function process() internal
        //(
        //    address /* msgSender*/,
        //    address /* signer*/,
        //    uint256 /* value*/
        //)
    {
        //real abi-encoded calldata,various length,parsed by compiler with selector
        //real calldata length, uint256                                 -318, -286
        //to,address,20                                                 -286, -266
        //chainId,uint256                                               -266, -234
        //beforeTimeStamp(0),beforeBlockNumber(1),uint256,              -234, -202
        //uniqueNonce,uint256                                           -202, -170
        //dependUniqueNonce,uint256                                     -170, -138
        //value,uint256                                                 -138, -106
        //onlyDesignatedSender,bool                                     -106, -105
        //designatedSender,address                                      -105, -85
        //signer, address                                               -85, -65
        //r,bytes32                                                     -65, -33
        //s,bytes32                                                     -33, -1
        //v,byte                                                        -1, -0

        /*
        use calldata and bytes slice to reduce gas,
        use memory to keep compatibility to old versions,
        */
        if (msg.data.length >= REAL_CALLDATA_LENGTH_FROM_RO) {

            bytes memory callData = msg.data;
            uint256 callDataLength = msg.data.length;

            //1, check length
            if (callDataLength - REAL_CALLDATA_LENGTH_FROM_RO != BytesLibrary.toUint256(callData, callDataLength - REAL_CALLDATA_LENGTH_FROM_RO)) {
                _return(address(0), address(0), 0);
            }

            //2, check "to"
            {
                address to = BytesLibrary.toAddress(callData, callDataLength - TO_ADDRESS_FROM_RO);
                if (msg.sender/*the msg.sender is the 'to' contract*/ != to) {
                    _return(address(0), address(0), 0);
                }
            }

            //3, check chainId
            {
                uint256 chainId = BytesLibrary.toUint256(callData, callDataLength - CHAIN_ID_FROM_RO);
                if (chainId != block.chainid) {
                    _return(address(0), address(0), 0);
                }
            }

            //4, check ttl
            {
                uint256 before = BytesLibrary.toUint256(callData, callDataLength - BEFORE_FROM_RO);
                if (before != uint256(0)) {

                    if (before >> 255 == uint256(0)) {
                        if (before > block.timestamp) {
                            _return(address(0), address(0), 0);
                        }
                    } else {
                        if (
                            (before << 1) >> 1
                            > block.number
                        ) {
                            _return(address(0), address(0), 0);
                        }
                    }
                }
            }

            //5, recover signer and check
            address signer = address(0);
            {
                bytes memory toSign = BytesLibrary.slice(callData, 0, callDataLength - R_FROM_RO);
                bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(toSign)));
                bytes32 r = BytesLibrary.toBytes32(callData, callDataLength - R_FROM_RO);
                bytes32 s = BytesLibrary.toBytes32(callData, callDataLength - S_FROM_RO);
                uint8 v = BytesLibrary.toUint8(callData, callDataLength - V_FROM_RO);
                signer = ecrecover(digest, v, r, s);

                address presumedSigner = BytesLibrary.toAddress(callData, callDataLength - SIGNER_FROM_RO);
                if (presumedSigner != signer) {
                    _return(address(0), address(0), 0);
                }
            }

            //6, check and update unique nonce
            uint256 uniqueNonce = BytesLibrary.toUint256(callData, callDataLength - UNIQUE_NONCE_FROM_RO);
            {
                if (_uniqueNonces[signer][uniqueNonce]) {
                    _return(address(0), address(0), 0);
                }
                _uniqueNonces[signer][uniqueNonce] = true;
            }

            {
                uint256 dependUniqueNonce = BytesLibrary.toUint256(callData, callDataLength - DEPEND_UNIQUE_NONCE_FROM_RO);
                if (dependUniqueNonce != 0 && !_uniqueNonces[signer][dependUniqueNonce]) {
                    _return(address(0), address(0), 0);
                }
            }

            //7, recover 'value'
            uint256 value = BytesLibrary.toUint256(callData, callDataLength - VALUE_FROM_RO);

            //8, recover 'designatedSender'
            address designatedSender = BytesLibrary.toAddress(callData, callDataLength - DESIGNATED_SENDER_FROM_RO);
            {
                uint8 onlyDesignatedSender = BytesLibrary.toUint8(callData, callDataLength - ONLY_DESIGNATED_SENDER_FROM_RO);
                if (onlyDesignatedSender != 0 && tx.origin != designatedSender) {
                    _return(address(0), address(0), 0);
                }
            }

            _return(designatedSender, signer, value);
        }

        _return(address(0), address(0), 0);
    }


    function _return(address designatedSender, address signer, uint256 value) pure internal {
        bytes memory returnData = abi.encode(designatedSender, signer, value);

        assembly{
            let length := mload(returnData)
            return (add(returnData, 0x20), length)
        }
    }
}
