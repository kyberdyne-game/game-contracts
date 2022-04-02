// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Base.sol";
import "./EnhancedMap.sol";
import "./EnhancedUniqueIndexMap.sol";


contract Proxy is Base, EnhancedMap, EnhancedUniqueIndexMap {
    constructor (address admin) {
        require(admin != address(0));
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(admin))));
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(0)));
        sysSaveSlotData(outOfServiceSlot, bytes32(uint256(0)));
        sysSaveSlotData(revertMessageSlot, bytes32(uint256(1)));
        //sysSetDelegateFallback(address(0));
        sysSaveSlotData(transparentSlot, bytes32(uint256(1)));

    }

    bytes32 constant adminSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("adminSlot"))))));

    bytes32 constant revertMessageSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("revertMessageSlot"))))));

    bytes32 constant outOfServiceSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("outOfServiceSlot"))))));

    //address <===>  index EnhancedUniqueIndexMap
    //0x2f80e9a12a11b80d2130b8e7dfc3bb1a6c04d0d87cc5c7ea711d9a261a1e0764
    bytes32 constant delegatesSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("delegatesSlot"))))));

    //bytes4 abi ===> address, both not 0x00
    //0xba67a9e2b7b43c3c9db634d1c7bcdd060aa7869f4601d292a20f2eedaf0c2b1c
    bytes32 constant userAbiSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSlot"))))));

    bytes32 constant userAbiSearchSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSearchSlot"))))));

    //0xe2bb2e16cbb16a10fab839b4a5c3820d63a910f4ea675e7821846c4b2d3041dc
    bytes32 constant userSigZeroSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userSigZeroSlot"))))));

    bytes32 constant transparentSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("transparentSlot"))))));


    event DelegateSet(address delegate, bool activated);
    event AbiSet(bytes4 abi, address delegate, bytes32 slot);
    event PrintBytes(bytes data);
    //===================================================================================

    //
    function sysCountDelegate() view public returns (uint256){
        return sysUniqueIndexMapSize(delegatesSlot);
    }

    function sysGetDelegateAddress(uint256 index) view public returns (address){
        return address(uint160(uint256(sysUniqueIndexMapGetValue(delegatesSlot, index))));
    }

    function sysGetDelegateIndex(address addr) view public returns (uint256) {
        return uint256(sysUniqueIndexMapGetIndex(delegatesSlot, bytes32(uint256(uint160(addr)))));
    }

    function sysGetDelegateAddresses() view public returns (address[] memory){
        uint256 count = sysCountDelegate();
        address[] memory delegates = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            delegates[i] = sysGetDelegateAddress(i + 1);
        }
        return delegates;
    }

    //add delegates on current version
    function sysAddDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {
            sysUniqueIndexMapAdd(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], true);
        }
    }

    //delete delegates
    //be careful, if you delete a delegate, the index will change
    function sysDelDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {

            //travers all abis to delete those abis mapped to the given address
            uint256 j;
            uint256 k;
            /*bytes4[] memory toDeleteSelectors = new bytes4[](count + 1);
            uint256 pivot = 0;*/
            uint256 count = sysCountSelectors();

            /*for (j = 0; j < count; j ++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetUserSelectorAndDelegateByIndex(j + 1);
                if (delegate == _inputs[i]) {
                    toDeleteSelectors[pivot] = selector;
                    pivot++;
                }
            }
            pivot = 0;
            while (toDeleteSelectors[pivot] != bytes4(0x00)) {
                sysSetUserSelectorAndDelegate(toDeleteSelectors[pivot], address(0));
                pivot++;
            }*/
            k = 1;
            for (j = 0; j < count; j++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetSelectorAndDelegateByIndex(k);
                if (delegate == _inputs[i]) {
                    _sysSetSelectorAndDelegate(selector, address(0));
                }
                else {
                    k++;
                }
            }

            if (sysGetSigZero() == _inputs[i]) {
                _sysSetSigZero(address(0x00));
            }

            sysUniqueIndexMapDelArrange(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], false);
        }
    }

    //add and delete delegates
    function sysReplaceDelegates(address[] memory _delegatesToDel, address[] memory _delegatesToAdd) external onlyAdmin {
        require(_delegatesToDel.length == _delegatesToAdd.length, "sysReplaceDelegates, length does not match");
        for (uint256 i = 0; i < _delegatesToDel.length; i ++) {
            sysUniqueIndexMapReplace(delegatesSlot, bytes32(uint256(uint160(_delegatesToDel[i]))), bytes32(uint256(uint160(_delegatesToAdd[i]))));
            emit DelegateSet(_delegatesToDel[i], false);
            emit DelegateSet(_delegatesToAdd[i], true);
        }
    }

    //=============================================

    function sysGetSigZero() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(userSigZeroSlot))));
    }

    function sysSetSigZero(address _input) external onlyAdmin {
        _sysSetSigZero(_input);
    }

    function _sysSetSigZero(address _input) internal {
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetAdmin() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(adminSlot))));
    }

    function sysSetAdmin(address _input) external onlyAdmin {
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetRevertMessage() view public returns (uint256){
        return uint256(sysLoadSlotData(revertMessageSlot));
    }

    function sysSetRevertMessage(uint256 _input) external onlyAdmin {
        sysSaveSlotData(revertMessageSlot, bytes32(_input));
    }

    function sysGetOutOfService() view public returns (uint256){
        return uint256(sysLoadSlotData(outOfServiceSlot));
    }

    function sysSetOutOfService(uint256 _input) external onlyAdmin {
        sysSaveSlotData(outOfServiceSlot, bytes32(_input));
    }

    function sysGetTransparent() view public returns (uint256){
        return uint256(sysLoadSlotData(transparentSlot));
    }

    function sysSetTransparent(uint256 _input) external onlyAdmin {
        sysSaveSlotData(transparentSlot, bytes32(_input));
    }

    //=============================================

    //abi and delegates should not be 0x00 in mapping;
    //set delegate to 0x00 for delete the entry
    function sysSetSelectorsAndDelegates(bytes4[] memory selectors, address[] memory delegates) external onlyAdmin {
        require(selectors.length == delegates.length, "sysSetUserSelectorsAndDelegates, length does not matchs");
        for (uint256 i = 0; i < selectors.length; i ++) {
            _sysSetSelectorAndDelegate(selectors[i], delegates[i]);
        }
    }

    function _sysSetSelectorAndDelegate(bytes4 selector, address delegate) internal {

        require(selector != bytes4(0x00), "sysSetSelectorAndDelegate, selector should not be selector");
        //require(delegates[i] != address(0x00));
        address oldDelegate = address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
        if (oldDelegate == delegate) {
            //if oldDelegate == 0 & delegate == 0
            //if oldDelegate == delegate != 0
            //do nothing here
        }
        if (oldDelegate == address(0x00)) {
            //delegate != 0
            //adding new value
            sysEnhancedMapAdd(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
            sysUniqueIndexMapAdd(userAbiSearchSlot, bytes32(selector));
        }
        if (delegate == address(0x00)) {
            //oldDelegate != 0
            //deleting new value
            sysEnhancedMapDel(userAbiSlot, bytes32(selector));
            sysUniqueIndexMapDel(userAbiSearchSlot, bytes32(selector));

        } else {
            //oldDelegate != delegate & oldDelegate != 0 & delegate !=0
            //updating
            sysEnhancedMapReplace(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
        }
    }

    function sysGetDelegateBySelector(bytes4 selector) view public returns (address){
        return address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
    }

    function sysCountSelectors() view public returns (uint256){
        return sysEnhancedMapSize(userAbiSlot);
    }

    function sysGetSelector(uint256 index) view public returns (bytes4){
        bytes4 selector = bytes4(sysUniqueIndexMapGetValue(userAbiSearchSlot, index));
        return selector;
    }

    function sysGetSelectorAndDelegateByIndex(uint256 index) view public returns (bytes4, address){
        bytes4 selector = sysGetSelector(index);
        address delegate = sysGetDelegateBySelector(selector);
        return (selector, delegate);
    }

    function sysGetSelectorsAndDelegates() view public returns (bytes4[] memory selectors, address[] memory delegates){
        uint256 count = sysCountSelectors();
        selectors = new bytes4[](count);
        delegates = new address[](count);
        for (uint256 i = 0; i < count; i ++) {
            (selectors[i], delegates[i]) = sysGetSelectorAndDelegateByIndex(i + 1);
        }
    }

    function sysClearSelectorsAndDelegates() external onlyAdmin {
        uint256 count = sysCountSelectors();
        for (uint256 i = 0; i < count; i ++) {
            bytes4 selector;
            address delegate;
            //always delete the first, after 'count' times, it will clear all
            (selector, delegate) = sysGetSelectorAndDelegateByIndex(1);
            _sysSetSelectorAndDelegate(selector, address(0x00));
        }
    }

    //=====================internal functions=====================

    receive() payable external {
        process();
    }

    fallback() payable external {
        process();
    }


    //since low-level address.delegateCall is available in solidity,
    //we don't need to write assembly
    function process() internal outOfService {

        if (msg.sender == sysGetAdmin() && sysGetTransparent() == 1) {
            revert("admin cann't call normal function in Transparent mode");
        }

        /*
        the default transfer will set data to empty,
        so that the msg.data.length = 0 and msg.sig = bytes4(0x00000000),

        however some one can manually set msg.sig to 0x00000000 and tails more man-made data,
        so here we have to forward all msg.data to delegates
        */
        address targetDelegate;

        //for look-up table
        /*        if (msg.sig == bytes4(0x00000000)) {
                    targetDelegate = sysGetUserSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    targetDelegate = sysGetSystemSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                } else {
                    targetDelegate = sysGetUserDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    //check system abi look-up table
                    targetDelegate = sysGetSystemDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                }*/

        if (msg.sig == bytes4(0x00000000)) {
            targetDelegate = sysGetSigZero();
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        } else {
            targetDelegate = sysGetDelegateBySelector(msg.sig);
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        }

        //goes here means this abi is not in the system abi look-up table
        discover();

        //hit here means not found selector
        if (sysGetRevertMessage() == 1) {
            revert(string(abi.encodePacked(sysPrintAddressToHex(address(this)), "function selector not found : ", sysPrintBytes4ToHex(msg.sig))));
        } else {
            revert();
        }

    }

    function discover() internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        address targetDelegate;
        uint256 len = sysCountDelegate();
        for (uint256 i = 0; i < len; i++) {
            targetDelegate = sysGetDelegateAddress(i + 1);
            (found, error, returnData) = redirect(targetDelegate, msg.data);


            if (found) {
                /*if (msg.sig == bytes4(0x00000000)) {
                    sysSetSystemSigZero(targetDelegate);
                } else {
                    sysSetSystemSelectorAndDelegate(msg.sig, targetDelegate);
                }*/

                returnAsm(error, returnData);
            }
        }
    }

    function delegateCallExt(address targetDelegate, bytes memory callData) internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        (found, error, returnData) = redirect(targetDelegate, callData);
        require(found, "delegateCallExt to a delegate in the map but finally not found, this shouldn't happen");
        returnAsm(error, returnData);
    }

    //since low-level ```<address>.delegatecall(bytes memory) returns (bool, bytes memory)``` can return returndata,
    //we use high-level solidity for better reading
    function redirect(address delegateTo, bytes memory callData) internal returns (bool found, bool error, bytes memory returnData){
        require(delegateTo != address(0), "delegateTo must not be 0x00");
        bool success;
        (success, returnData) = delegateTo.delegatecall(callData);
        if (success == true && keccak256(returnData) == keccak256(notFoundMark)) {
            //the delegate returns ```notFoundMark``` notFoundMark, which means invoke goes to wrong contract or function doesn't exist
            return (false, true, returnData);
        } else {
            return (true, !success, returnData);
        }

    }

    function sysPrintBytesToHex(bytes memory input) internal pure returns (string memory){
        bytes memory ret = new bytes(input.length * 2);
        bytes memory alphabet = "0123456789abcdef";
        for (uint256 i = 0; i < input.length; i++) {
            bytes32 t = bytes32(input[i]);
            bytes32 tt = t >> 31 * 8;
            uint256 b = uint256(tt);
            uint256 high = b / 0x10;
            uint256 low = b % 0x10;
            bytes1 highAscii = alphabet[high];
            bytes1 lowAscii = alphabet[low];
            ret[2 * i] = highAscii;
            ret[2 * i + 1] = lowAscii;
        }
        return string(ret);
    }

    function sysPrintAddressToHex(address input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintBytes4ToHex(bytes4 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintUint256ToHex(uint256 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    modifier onlyAdmin(){
        require(msg.sender == sysGetAdmin(), "only admin");
        _;
    }

    modifier outOfService(){
        if (sysGetOutOfService() == uint256(1)) {
            if (sysGetRevertMessage() == 1) {
                revert(string(abi.encodePacked("Proxy is out-of-service right now")));
            } else {
                revert();
            }
        }
        _;
    }

}
