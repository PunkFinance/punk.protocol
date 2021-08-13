// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RecoveryFund is ERC20Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address [] private _victims;
    address public addressOfDAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    uint256 public totalRefund;
    uint256 public refunded;

    constructor() ERC20("RecoveryFund", "peUSD") {
        _initialMint(address(0xe1cd21e5d6f4323E91dA943B0A4F1732acC7a138), 1213998517300000000000000);
        _initialMint(address(0xf49a12fE6a05bdFc7C0cd4FE2A19724CCFbA18d3), 898535671700000000000000);
        _initialMint(address(0x82dc92b01c7fF54911842956083795f60f6F64f4), 673946680643589900000000);
        _initialMint(address(0x8ed32Ed24303092c016Cdb24d51e153AD88c4875), 89858957570000000000000);
        _initialMint(address(0xf2CcE4EcB119038dA9F4E18F82E07bb555FbAe2C), 77613054250000000000000);
        _initialMint(address(0x5522234194F499F1DBF2E26C6eBD802bc2Cd9A2f), 77095278220000000000000);
        _initialMint(address(0x896b94f4f27f12369698C302e2049cAe86936BbB), 62897497019999995000000);
        _initialMint(address(0xac1f46771cF300bD4D43442960CD5e3d7476Ca34), 53912140300000000000000);
        _initialMint(address(0xa52D39E63900992F36286953F884E014AC1F688D), 53905401290000000000000);
        _initialMint(address(0xE5EC1103810217a3F83262C66c6a38a8e6387366), 53905401290000000000000);
        _initialMint(address(0x577502784eDd9b0D84d08334c30D378975e8F5AC), 45751912140000000000000);
        _initialMint(address(0x469Adaf766fb35F1a3c2569FE8C57a50F4B39131), 45355619800000000000000);
        _initialMint(address(0x544Fc1845DF225679f5A939eF930837B8cBA0552), 44926783590000000000000);
        _initialMint(address(0x4c3a58357f42a7741F61D2c7Fa3e7700996A5A60), 44920044570000000000000);
        _initialMint(address(0xD9F0834E7Ca9B9262Df3189b850eBf9514027e82), 38383197560000000000000);
        _initialMint(address(0x3E269201B45622c88E1cca18CE9A02609d4D2A54), 35934687850000000000000);
        _initialMint(address(0xe9017c8De5040968D9752A18d805cD2A983E558c), 32003782980000000000000);
        _initialMint(address(0x55d72CbcbA1Ab5C784bC52641D16c613E3b9BAD4), 31755408880000000000000);
        _initialMint(address(0xf76CF36f638c7bCD83f4756beDb86243D98982F9), 29253624400000000000000);
        _initialMint(address(0x29227FB595D091bcA244E76201c0dd50641D96C8), 27239560830000002000000);
        _initialMint(address(0x2572a193DA3DEf3BAeA04cB18e06A52186aC1a98), 26954824385000000000000);
        _initialMint(address(0x81a7E267Fd8339a01beb175f5A3d644FcF0B48Dc), 24234548190999998000000);
        _initialMint(address(0x67D33CF1C7c699078f86D517A5a1cd1444A1E85C), 23536011086000000000000);
        _initialMint(address(0x78d58Cc37cDAaBFde72c9a45B57Acbc3aBc3D7C9), 22546913770000000000000);
        _initialMint(address(0x9dcAfb9A5A2A948ee7A70cDce6abC46322171ACD), 22463391790000000000000);
        _initialMint(address(0x28C01B64F2492D82fd58FEECF8c71603c769BB4A), 22458456610000000000000);
        _initialMint(address(0xE01f94F635028394cB15B572179DaEbbfC231761), 20217052610000000000000);
        _initialMint(address(0x58e316d51aDA862d71fBa22ADA6f56D00186Af13), 18190064880000000000000);
        _initialMint(address(0x09CF915e195aF33FA7B932C253352Ae9FBdB0106), 18090301810000000000000);
        _initialMint(address(0x833A11B69873151fBA6D14f455db5392542825Ca), 17970855662000000000000);
        _initialMint(address(0xffD851CFE0A50E1f1Cf2739Fc6D97754d49943a0), 17303601743000000000000);
        _initialMint(address(0xe43458e1F964EEf5F707E81fb6f16Ab27c261071), 16930658390000000000000);
        _initialMint(address(0x185C034Bdc0ca1d66Dc75650D33DEA190315595b), 14422499490000000000000);
        _initialMint(address(0x0056BcFe33f5c6DfA62B6d3d3CF5A957429828BB), 14104489260000000000000);
        _initialMint(address(0x963aD4Cc7798601cC36526162FDa203C21E90872), 13602254460000000000000);
        _initialMint(address(0x6FdED91556cfBf602f05e279d270327382d9206E), 13471296060000000000000);
        _initialMint(address(0xbEcB3451c1724Ce87801e6A09b547bB704e47884), 13380094687000000000000);
        _initialMint(address(0x00F928a6aDC7c345EF919fe5A8Be2458580eF9f6), 11227034090000000000000);
        _initialMint(address(0x241a119A8C634b58E78Ec4Ce9bF786756f9FD310), 8985356717000000000000);
        _initialMint(address(0xd6b4D675F749F951B706Da0dF2CF99f913143B0C), 8985356717000000000000);
        _initialMint(address(0x956D079B656a3955AB4f2f596d1bbfd6F3Ae60dC), 5197498877000000000000);
        _initialMint(address(0x53274F93Bcf4647C39E8Af160226736c037574e6), 5177541065000000000000);
        _initialMint(address(0x57d6C4efB2cA6703674343d1a7c0492fba49A6f3), 4492678359000000000000);
        _initialMint(address(0xA2F8e4744FD85E9089a337fed259F05dd864a91e), 4492678359000000000000);
        _initialMint(address(0xDcbBf294D08F70571666f7d08BBDf93189341B0e), 4488634499000000000000);
        _initialMint(address(0xc28466bBD0F2f519829fEaEBA61470A381c5d07b), 4348912651000000000000);
        _initialMint(address(0x7c25bB0ac944691322849419DF917c0ACc1d379B), 4043410523000000000000);
        _initialMint(address(0xf6cDbA86999372f8B9104234885edFDAA1Eb01D1), 3832978820000000300000);
        _initialMint(address(0x72f6A96a49B41467eef03924211e422Eaf639e3f), 3813708894000000000000);
        _initialMint(address(0x9412b1e09ad73Dff95D099B2d1eFCD389c1422cf), 2243161150000000000000);
        _initialMint(address(0x27EF5f1Fa276E8394681A260F77208ccD0305013), 1827100390000000000000);
        _initialMint(address(0xB1f72d694711FcE55C62eA97BD3739Ff11ceF986), 1790766736000000000000);
        _initialMint(address(0xE81e90222E0BD7D114cce6495B57C307Df342373), 1682368129000000000000);
        _initialMint(address(0x7bF4aef8731377eC73a53f5032092d1699c56526), 1349221073000000000000);
        _initialMint(address(0x38Bc5196d8b21782372a843E5A505d9F457e6ff8), 1311525431000000000000);
        _initialMint(address(0x7E1BeE475e5EFF0e0810cfd1a940c50d7294f15F), 1156118143000000000000);
        _initialMint(address(0xac1886d1ef0a19aFb8392ae4231472d4bBF39c4F), 1118439356000000000000);
        _initialMint(address(0xd40Cd4D9f9BcF3fE57E37bC88EbFDB6ad2244578), 1108871318000000000000);
        _initialMint(address(0x3F8a2B94578D73AF4CBE63C38D2C481Cc7D09F98), 949716401200000000000);
        _initialMint(address(0xf934a267C6fB6170FAf5940fb3c12033a1f14d74), 924521947800000000000);
        _initialMint(address(0xEcc03538d9Af264725dABd36417441F7971c91F6), 898535671700000000000);
        _initialMint(address(0x41833aAE8C10641045fFA17E2377919201A71dDb), 896733830900000000000);
        _initialMint(address(0xe75D13941a26be0d5E5C1a104494eFC67dEAfb38), 693526172300000000000);
        _initialMint(address(0x9b95F760A7eBCd6dFbEb91FACdA9B8ac2296820f), 633523800100000000000);
        _initialMint(address(0x9bb64e40DCBe4645F99F0a9e2507b5A53795fa70), 580593317000000000000);
        _initialMint(address(0x8eA035d0995F0568969020A00D1891d1D29c7517), 461972401500000000000);
        _initialMint(address(0x5E87597C7eCD23bA209B5354881e4Cafd2FC4D28), 457250243900000000000);
        _initialMint(address(0xa3eC8fB0aCc93d0BB8CA73B9e90FE57275855E94), 358417937300000000000);
        _initialMint(address(0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3), 314487485100000000000);
        _initialMint(address(0xD47835d494AC1Bf8C140B6A04E69b67e75928022), 262821684000000000000);
        _initialMint(address(0x8e0e3D4a18AA44904ebda87C5B42545d1cEC2e5f), 213698063100000000000);
        _initialMint(address(0xB444b304C55fa9c6fa995a758CBd5a96cF84782B), 64620692110000000000);
        _initialMint(address(0x8E1D10aaeF9c0C0D337Aa47022BF0d96D21b56B9), 49312416690000000000);
        totalRefund = totalSupply();
        _pause();
    }

    function _initialMint(address account, uint256 amount) internal whenNotPaused{
        require(balanceOf(account) == 0, "REFUND : account has tokens");
        _mint(account, amount);
        _victims.push(account);
    }

    function minRefundAmount() public view returns(uint256){
        return totalSupply().div(balanceOf(address(0x8E1D10aaeF9c0C0D337Aa47022BF0d96D21b56B9)));
    }

    function refund( uint256 refundAmount ) public nonReentrant returns(bool){
        require( IERC20(addressOfDAI).allowance(msg.sender, address(this)) >= refundAmount, "REFUND : allowance is insufficient" );
        require( IERC20(addressOfDAI).balanceOf(msg.sender) >= refundAmount, "REFUND : sender's balance is insufficient" );
        require( minRefundAmount() <= refundAmount, "REFUND : refundAmount less than minRefundAmount" );
        
        IERC20 DAI = IERC20(addressOfDAI);
        uint256 guaranteedSupply = totalSupply();
        uint256 amountToBeSent = refundAmount.sub( refundAmount.mod(minRefundAmount()) );
        uint256 amountSent = 0;
        uint8 i = 0;
        
        _unpause();
        for (i; i < _victims.length; i++) {
            uint value = amountToBeSent.mul( balanceOf(_victims[i]) ).div( guaranteedSupply );
            require( value > 0, "REFUND : sent value is zero" );
            _burn(_victims[i], value);
            DAI.safeTransferFrom(msg.sender, _victims[i], value);
            amountSent += value;
        }
        _pause();

        require( guaranteedSupply.sub(amountSent) == totalSupply(), "REFUND : guaranteedSupply is not amount sent" );
        refunded += amountSent;
        return false;
    }

}
