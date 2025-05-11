namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetUserGroupsResponse
{
    public required IEnumerable<UserGroup> UserGroups { get; init; }
}

public sealed class UserGroup
{
    public required int Id { get; init; }
    public required string Name { get; init; }
}