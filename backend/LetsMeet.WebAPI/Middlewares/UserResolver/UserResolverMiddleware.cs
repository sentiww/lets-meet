namespace LetsMeet.WebAPI.Middlewares.UserResolver;

internal sealed class UserResolverMiddleware : IMiddleware
{
    private readonly IUserResolver _userResolver;

    public UserResolverMiddleware(IUserResolver userResolver)
    {
        _userResolver = userResolver;
    }

    public Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        if (context.User.Claims.Any())
        {
            _userResolver.Bind(context.User.Claims);
        }
        
        return next(context);
    }
}