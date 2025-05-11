using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class GetUserGroupRequest
{
    [FromQuery]
    public required int UserGroupId { get; init; }
}