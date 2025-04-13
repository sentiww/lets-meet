using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Options;
using LetsMeet.WebAPI.Services.AuthenticationService;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace LetsMeet.WebAPI.Services.ApplicationConfigurationService;

internal sealed class ApplicationConfigurationService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    
    public ApplicationConfigurationService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await using var scope = _serviceProvider.CreateAsyncScope();

        var adminOptions = scope.ServiceProvider.GetRequiredService<IOptions<AdminOptions>>();
        await HandleAdminConfigurationAsync(adminOptions.Value, stoppingToken);
    }

    private async ValueTask HandleAdminConfigurationAsync(AdminOptions options, CancellationToken cancellationToken)
    {
        if (options.EnsureExists is false)
        {
            return;
        }
        
        await using var scope = _serviceProvider.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<LetsMeetDbContext>();
        
        var admin = await context.Users.FirstOrDefaultAsync(u => u.Username == options.Username, cancellationToken);
        if (admin is null)
        {
            var authenticationService = scope.ServiceProvider.GetRequiredService<IAuthenticationService>();
            
            admin = new UserEntity
            {
                Username = options.Username,
                PasswordHash = authenticationService.HashPassword(options.Password),
                Name = options.Name,
                Surname = options.Surname,
                DateOfBirth = options.DateOfBirth,
                Email = options.Email
            };
            
            context.Users.Add(admin);
            
            await context.SaveChangesAsync(cancellationToken);
        }
    }
}