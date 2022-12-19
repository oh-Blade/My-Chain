pragma solidity ^0.5.0;

contract NoteContract{
    mapping(address => string []) public notes;

    constructor() public {

    }

    event NewNote(address,string note);

    function addNote(string memory note) public{
        notes[msg.sender].push(note);
        emit NewNote(msg.sender, note);
    }


}