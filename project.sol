// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityPlaylistRewards {
    // Playlist structure
    struct Playlist {
        uint256 id;
        string name;
        address creator;
        uint256 votes;
    }

    address public owner;
    uint256 public playlistCount = 0;
    uint256 public rewardPool = 0;
    uint256 public rewardPerVote = 1 ether; // Reward per vote in Wei

    mapping(uint256 => Playlist) public playlists;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event PlaylistCreated(uint256 id, string name, address creator);
    event Voted(uint256 playlistId, address voter);
    event RewardsDistributed(uint256 playlistId, address creator, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Allow the owner to fund the reward pool
    function fundRewardPool() public payable onlyOwner {
        require(msg.value > 0, "Funding amount must be greater than zero");
        rewardPool += msg.value;
    }

    // Create a new playlist
    function createPlaylist(string memory _name) public {
        playlistCount++;
        playlists[playlistCount] = Playlist(playlistCount, _name, msg.sender, 0);
        emit PlaylistCreated(playlistCount, _name, msg.sender);
    }

    // Vote for a playlist
    function voteForPlaylist(uint256 _playlistId) public {
        require(_playlistId > 0 && _playlistId <= playlistCount, "Invalid playlist ID");
        require(!hasVoted[_playlistId][msg.sender], "You have already voted for this playlist");

        playlists[_playlistId].votes++;
        hasVoted[_playlistId][msg.sender] = true;

        emit Voted(_playlistId, msg.sender);
    }

    // Distribute rewards to the playlist creator
    function distributeRewards(uint256 _playlistId) public {
        require(_playlistId > 0 && _playlistId <= playlistCount, "Invalid playlist ID");
        Playlist storage playlist = playlists[_playlistId];
        require(playlist.votes > 0, "No votes for this playlist");
        require(address(this).balance >= playlist.votes * rewardPerVote, "Insufficient reward pool");

        uint256 reward = playlist.votes * rewardPerVote;
        rewardPool -= reward;
        payable(playlist.creator).transfer(reward);

        emit RewardsDistributed(_playlistId, playlist.creator, reward);
    }

    // Retrieve contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
