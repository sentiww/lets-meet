namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class PostUserGroupRequest
{
    public required string Name { get; init; }
    public string? Topic { get; init; }

}