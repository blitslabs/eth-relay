pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";


contract IdenaWorldState is Ownable {
    uint256 private _epoch;

    struct IdState {
        // last birth epoch
        uint32 birth;
        // 1 for Newbie, Verified, Human
        // 0 for others(Unkown, Killed, Suspended, Candidate)
        uint16 state;
    }
    // Identities of latest epoch, the array size grow only, size is controlled by _populcation
    address[] private _identities;
    uint256 _population;
    // identity states
    mapping(address => IdState) private _states;

    bool private _initialized;

    event NewEpoch(uint256 epoch, uint256 population);

    constructor() public {}

    /**
     * @dev Initialize `epoch` and identities' states
     *
     * Emits a {NewEpoch} event.
     */
    function init(
        uint256 epoch,
        address[] memory identities,
        uint256[] memory states
    ) public onlyOwner {
        require(!_initialized, "Initialization can only be called once.");
        require(
            identities.length == states.length,
            "Array length not match for identities and states."
        );

        _initialized = true;
        _epoch = epoch;
        uint256 state;
        address addr;
        for (uint256 i = 0; i < identities.length; i++) {
            addr = identities[i];
            state = states[i];
            require(state > 0, "Invalid identity state.");
            require(_states[addr].state == 0, "Duplicated identity");
            _states[addr] = IdState(uint32(epoch), uint16(state));
            _identities.push(addr);
        }
        _population = _identities.length;
        emit NewEpoch(_epoch, _population);
    }

    /**
     * @dev Update changed identities' states for each new epoch
     *
     * Emits a {NewEpoch} event.
     */
    function nextEpoch(
        address[] memory diffIdentities,
        uint256[] memory diffStates,
        uint256[] memory signature
    ) public {
        require(
            diffIdentities.length == diffStates.length,
            "Array length not match"
        );

        // todo: check signature satisfy the 2/3

        // todo: update _identities, _states, _population

        _epoch++;
        emit NewEpoch(_epoch, _population);
    }

    function initialized() public view returns (bool) {
        return _initialized;
    }

    function epoch() public view returns (uint256) {
        return _epoch;
    }

    function population() public view returns (uint256) {
        return _population;
    }

    function identities() public view returns (address[] memory) {
        address[] memory result = new address[](_population);
        for (uint256 i = 0; i < _population; i++) {
            result[i] = _identities[i];
        }
        return result;
    }

    function State(address identity) public view returns (IdState memory) {
        return _states[identity];
    }
}
