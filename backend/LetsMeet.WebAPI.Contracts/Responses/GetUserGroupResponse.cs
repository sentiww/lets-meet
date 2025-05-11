namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetUserGroupResponse
{
    public int Id { get; init; }
    public string Name { get; init; }
    public string? Topic { get; init; }
    public int CreatedByUserId { get; init; }
    public DateTime CreatedAt { get; init; }
}