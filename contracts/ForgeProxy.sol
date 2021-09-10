// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "./OwnableStorage.sol";

contract ForgeProxy is Proxy {
    event Upgraded(address indexed implementation);
    event RequestUpgradTo(address nextImplementation, uint256 nextImplementationTimestamp );

    uint256 private constant DELAY_TIME = 48 hours;

    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _NEXT_IMPLEMENTATION_SLOT =
        0x386fd0873c4dae4047292a961c4d79fea20281d6344fde0002a91190c29439e0;
    bytes32 private constant _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT =
        0x2f4ec45a1b013d9051b3ed7cdfb2a5b3e28368f1dafac0e7898229fb9db98dca;
    bytes32 private constant _OWNABLE_STORAGE_SLOT =
        0xb39836d625a4efe66fcfaa81a972ba97548a953a597399c161cd7df952bcf2e8;
    bytes32 private constant _INITIALIZE_SLOT =
        0x5995627934808137c9bf9d6f83d56749658ca23d1b6461c2a912ee34403ccd6a;

    modifier isInitializer() {
        require(
            getInitialize() != 1,
            "Initializable: contract is already initialized"
        );
        _;
    }

    modifier CheckAdmin() {
        require(OwnableStorage(_storage()).isAdmin(msg.sender), "OWNABLE: 0x0");
        _;
    }
    
    modifier onlyAdminOrGovernance() {
        require(OwnableStorage(_storage()).isAdmin(msg.sender) || OwnableStorage(_storage()).isGovernance(msg.sender), "OWNABLE: 0x0");
        _;
    }

    function initialize(address storage_, address implAddress)
        public
        isInitializer
    {
        require(
            _IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        require(
            _OWNABLE_STORAGE_SLOT ==
                bytes32(uint256(keccak256("forge.proxy.ownablestrage")) - 1)
        );
        require(
            _INITIALIZE_SLOT ==
                bytes32(uint256(keccak256("forge.proxy.initialize")) - 1)
        );

        _setImplementation(implAddress);
        _setStorage(storage_);
        _setInitialize();
    }

    function _storage() internal view returns (address storageAddr) {
        bytes32 slot = _OWNABLE_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageAddr := sload(slot)
        }
    }

    function _setStorage(address storage_) internal {
        bytes32 slot = _OWNABLE_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, storage_)
        }
    }

    function _nextImplementation() internal view returns (address nextImplementation) {
        bytes32 slot = _NEXT_IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            nextImplementation := sload(slot)
        }
    }

    function _setNextImplementation(address storage_) internal {
        bytes32 slot = _NEXT_IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, storage_)
        }
    }

    function _nextImplementationTimestamp() internal view returns (uint256 nextImplementationTimestamp) {
        bytes32 slot = _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            nextImplementationTimestamp := sload(slot)
        }
    }

    function _setNextImplementationTimestamp(uint256 nextImplementationTimestamp) internal {
        bytes32 slot = _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, nextImplementationTimestamp)
        }
    }

    function requestUpgradeTo(address newImplementation) public onlyAdminOrGovernance {
        require( newImplementation != address(0), "" );
        require( Address.isContract(newImplementation), "");

        _setNextImplementation(newImplementation);
        _setNextImplementationTimestamp(block.timestamp + DELAY_TIME);

        emit RequestUpgradTo(_nextImplementation(), _nextImplementationTimestamp());
    }

    function upgradeAccept(address ) public onlyAdminOrGovernance {
        require( _nextImplementation() != address(0), "" );
        require( _nextImplementationTimestamp() <= block.timestamp, "" );
        
        _setImplementation(_nextImplementation());
        emit Upgraded(_nextImplementation());
    }

    function _setImplementation(address newImplementation) private {
        require(
            Address.isContract(newImplementation),
            "ERC1967Proxy: new implementation is not a contract"
        );

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _implementation() internal view override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    function _setInitialize() internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_INITIALIZE_SLOT, 1)
        }
    }

    function getInitialize() private view returns (uint256 str) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(_INITIALIZE_SLOT)
        }
    }

}
