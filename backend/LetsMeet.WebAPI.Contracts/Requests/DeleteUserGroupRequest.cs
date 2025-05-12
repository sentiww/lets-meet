using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class DeleteUserGroupRequest
{
    [FromQuery]
    public required int UserGroupId { get; init; }
}