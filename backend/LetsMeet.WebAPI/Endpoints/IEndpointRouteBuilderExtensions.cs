namespace LetsMeet.WebAPI.Endpoints;

internal static class IEndpointRouteBuilderExtensions
{
    public static IEndpointRouteBuilder MapEndpoints(
        this IEndpointRouteBuilder routeBuilder)
    {
        var apiGroup = routeBuilder.MapGroup("/api/v1");

        apiGroup.MapAuthEndpoints();
        apiGroup.MapUserEndpoints();
        apiGroup.MapFriendEndpoints();
        apiGroup.MapBlockEndpoints();
        apiGroup.MapBlobEndpoints();
        apiGroup.MapEventEndpoints();
        apiGroup.MapUserGroupEndpoints();
        apiGroup.MapChatEndpoints();
        
        return routeBuilder;
    }
}