namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class PutUserGroupRequest
{
    public required string Name { get; init; }
    public string? Topic { get; init; }

}