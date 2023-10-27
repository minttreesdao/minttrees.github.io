// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RSPSinglePlayerGS {
    enum Move { None, Rock, Scissors, Paper }
    
    struct Player {
        address addr;
        bytes32 moveHash;
        Move move;
    }
    
    Player public player;
    Move public contractMove = Move.None;
    mapping(Move => Move) winnerMove;

    constructor() {
        winnerMove[Move.Rock] = Move.Paper;
        winnerMove[Move.Scissors] = Move.Rock;
        winnerMove[Move.Paper] = Move.Scissors;
    }
   
    function joinAndReveal(Move joinMove, string memory secret) public {
        require(player.addr == address(0), "Game is already in progress");
        bytes32 moveHash = keccak256(abi.encodePacked(joinMove, secret));
        player = Player(msg.sender, moveHash, joinMove);
        contractMove = Move((uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 3) + 1);
    }

    function winner() public view returns (address) {
        if (player.move == contractMove || player.move == Move.None || contractMove == Move.None) return address(0);
        return (player.move == winnerMove[contractMove]) ? player.addr : address(this);
    }

    function reset() public {
        require(player.addr == msg.sender, "Only the player can reset the game");
        require(player.move != Move.None, "The game has not yet ended");
        player = Player(address(0), 0, Move.None);
        contractMove = Move.None;
    }
}
