namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetUsersResponse
{
    public required IEnumerable<User> Users { get; init; }

    public sealed class User
    {
        public required int Id { get; init; }
        public required string Username { get; init; }
    }
}
