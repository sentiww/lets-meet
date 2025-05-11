using System;

namespace LetsMeet.WebAPI.Contracts.Requests;

public class RemoveFriendRequest
{
    public required int FriendId { get; set; }
}
