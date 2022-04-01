// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DeputyRefLayout.sol";
import "../nameServiceRef/NameServiceRefLogic.sol";
import "./DeputyRefInterface.sol";

import "../deputyCenter/DeputyCenterInterface.sol";
import "../nameService/NameServiceInterface.sol";
import "../nameService/NameServiceType.sol";

contract DeputyRefLogic is DeputyRefLayout, NameServiceRefLogic, DeputyRefInterface {

    //remember to call this modifier at first to check msg.value
    //this function IGNORES designatedSender, the business logic could add this in param
    modifier onlyEnableDeputyAndSignerIsServer(){

        (address designatedSender, address signer, uint256 value) = checkDeputy();
        require(signer != address(0), "deputy: parse deputy fails");
        require(isServer(signer), "deputy: signer is not authed server");
        uint256 msgValue;
        assembly{
            msgValue := callvalue()
        }
        require(value <= msgValue, "deputy: value mismatch");
        _;
    }

    modifier onlyEnableDeputyAndSignerIsSpecified(address desiredSigner){
        (address designatedSender, address signer, uint256 value) = checkDeputy();
        require(signer != address(0), "deputy: parse deputy fails");
        require(signer == desiredSigner, "deputy: signer is not desired");
        uint256 msgValue;
        assembly{
            msgValue := callvalue()
        }
        require(value <= msgValue, "deputy: value mismatch");
        _;
    }

    modifier onlyEnableDesignatedSenderAndSignerIsServer(address desiredDesignatedSender){
        (address designatedSender, address signer, uint256 value) = checkDeputy();

        require(signer != address(0), "deputy: parse deputy fails");
        require(isServer(signer), "deputy: signer is not authed server");
        require(designatedSender == desiredDesignatedSender, "deputy: desiredDesignatedSender mismatch");

        uint256 msgValue;
        assembly{
            msgValue := callvalue()
        }
        require(value <= msgValue, "deputy: value mismatch");
        _;
    }

    modifier onlyMsgDotSenderOrDesignatedSender(address desiredMsgSender){
        (address designatedSender, address signer, uint256 value) = checkDeputy();

        if (signer == address(0)) {
            //check deputy fails
            require(msg.sender == desiredMsgSender, "deputy: parse deputy fails, but msg.sender != desiredMsgSender");
        } else {
            //check deputy success
            require(designatedSender == desiredMsgSender, "deputy: parse deputy success, but designatedSender != desiredMsgSender");
        }
        uint256 msgValue;
        assembly{
            msgValue := callvalue()
        }
        require(value <= msgValue, "value mismatch");
        _;
    }

    function checkDeputy() internal returns (address, address, uint256){
        bytes memory callData = msg.data;

        (bool success, bytes memory returnData) = deputyCenter().call(callData);
        require(success, "deputy, error");

        (address designatedSender, address signer, uint256 value) = abi.decode(returnData, (address, address, uint256));

        return (designatedSender, signer, value);
    }
}
