namespace LetsMeet.WebAPI.Middlewares.UserResolver;

public static class UserResolverExtensions
{
    public static void AddUserResolver(this IServiceCollection services)
    {
        services.AddScoped<UserResolverMiddleware>();
        services.AddScoped<IUserResolver, UserResolver>();
    }
    
    public static void UseUserResolver(this IApplicationBuilder app)
    {
        app.UseMiddleware<UserResolverMiddleware>();
    }
}