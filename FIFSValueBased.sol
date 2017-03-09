pragma solidity ^0.4.0;

import 'interface.sol';

/**
 * A registrar that allocates subdomains to the first person to claim them.
 */
contract FIFSRegistrar {
    AbstractENS ens;
    bytes32 rootNode;
    address mewAddress;
    modifier only_owner(string subnode) {
        var currentOwner = getCurrentOwner(subnode);
        if(currentOwner != 0 && currentOwner != msg.sender)
            throw;
        _;
    }

    modifier only_mew() {
        if (msg.sender != mewAddress) throw;
        _;
    }
    
    function FIFSRegistrar(address ensAddr, bytes32 node, address _mewOwner) {
        ens = AbstractENS(ensAddr);
        rootNode = node;
        mewAddress = _mewOwner;
    }

    function getCurrentOwner(string subnode) constant returns (address){
        var node = sha3(rootNode, sha3(subnode));
        return ens.owner(node);
    }

    function setMewAddress(address _add) only_mew {
        mewAddress = _add;
    }

    function withdraw(address _add) only_mew {
        address contractAdd = this;
        mewAddress.transfer(contractAdd.balance);
    }

    function changeRootNodeOwner(address _add) only_mew {
        ens.setOwner(rootNode, _add);
    }
   
    function register(string subnode, address owner) only_owner(subnode) {
        var currentOwner = getCurrentOwner(subnode);
        if(currentOwner == msg.sender) {
            ens.setSubnodeOwner(rootNode, sha3(subnode), owner);
        } else {
            var _value = msg.value;
            var _length = subnode.length;
            if(_length < 4 && _value < 3 ether) throw;
            else if (_length < 7 && _value < 2 ether) throw;
            else if (_length < 10 && _value < 1 ether) throw;
            else if(_length < 13 && _value < 0.5 ether) throw;
            else if(_length >= 13 && _value < 0.01 ether) throw;
            ens.setSubnodeOwner(rootNode, sha3(subnode), owner);
        }
    }
}
