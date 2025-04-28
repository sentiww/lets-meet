using System.Reflection;
using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.Persistence.Migrations;
using LetsMeet.WebAPI.Options;
using LetsMeet.WebAPI.Services.AssetService;
using LetsMeet.WebAPI.Services.AuthenticationService;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace LetsMeet.WebAPI.Services.ApplicationConfigurationService;

internal sealed class ApplicationConfigurationService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;

    // Assembly marker
    private readonly Assembly _migrationAssembly = typeof(Init).Assembly;
    
    public ApplicationConfigurationService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await using var scope = _serviceProvider.CreateAsyncScope();

        var context = scope.ServiceProvider.GetRequiredService<LetsMeetDbContext>();
        await context.Database.MigrateAsync(stoppingToken);
        
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
            var assetService = scope.ServiceProvider.GetRequiredService<IAssetService>();
            
            var avatarFile = assetService.Get("avatar.jpg");
            var avatarBytes = new byte[avatarFile.Length];
            await using var avatarStream = avatarFile.CreateReadStream();
            await avatarStream.ReadExactlyAsync(avatarBytes, 0, (int)avatarFile.Length, cancellationToken);
            
            var avatar = new BlobEntity
            {
                Name = "avatar",
                Extension = "jpg",
                Data = avatarBytes,
                ContentType = "image/jpeg"
            };

            context.Blobs.Add(avatar);
            
            await context.SaveChangesAsync(cancellationToken);
            
            admin = new UserEntity
            {
                Username = options.Username,
                PasswordHash = authenticationService.HashPassword(options.Password),
                Name = options.Name,
                Surname = options.Surname,
                DateOfBirth = options.DateOfBirth.UtcDateTime,
                Email = options.Email,
                Avatar = avatar
            };

            avatar.Owner = admin;
            
            context.Users.Add(admin);
            
            await context.SaveChangesAsync(cancellationToken);
        }
    }
}