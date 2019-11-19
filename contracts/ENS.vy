# ENS registrar

struct Node:
    resolver: address
    owner: address
    ttl: uint256

# Events
# NewResolver(bytes32,address)
NewResolver: event({node: indexed(bytes32), new_resolver: address})
# NewTTL(bytes32,uint64)
NewTTL: event({node: indexed(bytes32), new_ttl: uint256})
# NewOwner(bytes32,bytes32,address)
NewOwner: event({
    node: indexed(bytes32),
    label: indexed(bytes32),
    new_owner: address
})
# Transfer(bytes32,address)
Transfer: event({node: indexed(bytes32), to: address})

# Globals
nodes: map(bytes32, Node)  # node -> Node(resolver,owner,ttl)
# node_labels: map(bytes32, map(bytes32, address))  # node -> -> label -> owner

@public
def __init__():
    # Set 0x0 (root) owner.
    self.nodes[EMPTY_BYTES32] = Node({
        resolver: ZERO_ADDRESS,
        owner: msg.sender,
        ttl: 0
    })
    log.Transfer(EMPTY_BYTES32, msg.sender)

# resolver(bytes32)
@public
def resolver(node: bytes32) -> address:
    return self.nodes[node].resolver

# owner(bytes32)
@public
def owner(node: bytes32) -> address:
    return self.nodes[node].owner

# ttl(bytes32)
@public
def ttl(node: bytes32) -> uint256:
    return self.nodes[node].ttl

# setOwner(bytes32,address)
@public
def setOwner(node: bytes32, new_owner: address):
    assert msg.sender == self.nodes[node].owner
    self.nodes[node].owner = new_owner
    log.Transfer(node, new_owner)

# setSubnodeOwner(bytes32,bytes32,address)
@public
def setSubnodeOwner(node: bytes32, label: bytes32, new_owner: address):
    assert msg.sender == self.nodes[node].owner
    subnode: bytes32 = keccak256(concat(node, label))
    self.nodes[subnode].owner = new_owner
    log.NewOwner(node, label, new_owner)

# setResolver(bytes32,address)
@public
def setResolver(node: bytes32, resolver: address):
    assert msg.sender == self.nodes[node].owner
    self.nodes[node].resolver = resolver
    log.NewResolver(node, resolver)

# Alias for setTTL(bytes32,uint64)
# setTTL alias, for handling uint64.
@public
def TZZEoiecHP(node: bytes32, ttl: uint256):
    assert msg.sender == self.nodes[node].owner
    self.nodes[node].ttl = ttl
    raw_log(
        [keccak256(b"NewTTL(bytes32,uint64)"), node],
        convert(ttl, bytes32)
    )
