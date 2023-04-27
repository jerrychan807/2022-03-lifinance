// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import "./Swapper.sol";

/**
 * @title Generic Swap Facet
 * @author Li.Finance (https://li.finance)
 * @notice Provides functionality for swapping through ANY DEX
 * @dev Uses calldata to execute arbitrary methods on DEXs
 */
contract GenericSwapFacet is ILiFi, Swapper {
    /* ========== Public Functions ========== */

    /**
     * @notice Performs a swap and that's it
     * @param _lifiData data used purely for tracking and analytics
     * @param _swapData an array of swap related data for performing swaps before bridging
     */
    function swapTokensGeneric(LiFiData memory _lifiData, LibSwap.SwapData[] calldata _swapData) public payable {
        // 目标资产余额
        uint256 receivingAssetIdBalance = LibAsset.getOwnBalance(_lifiData.receivingAssetId);

        // Swap
        _executeSwaps(_lifiData, _swapData);
        // 多出来的目标资产余额
        uint256 postSwapBalance = LibAsset.getOwnBalance(_lifiData.receivingAssetId) - receivingAssetIdBalance;
        // 多出来的资产还给用户
        LibAsset.transferAsset(_lifiData.receivingAssetId, payable(msg.sender), postSwapBalance);

        emit LiFiTransferStarted(
            _lifiData.transactionId,
            _lifiData.integrator,
            _lifiData.referrer,
            _lifiData.sendingAssetId,
            _lifiData.receivingAssetId,
            _lifiData.receiver,
            _lifiData.amount,
            _lifiData.destinationChainId,
            block.timestamp
        );
    }
}
