using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class GetBlobRequest
{
    [FromQuery]
    public required int BlobId { get; init; }
}