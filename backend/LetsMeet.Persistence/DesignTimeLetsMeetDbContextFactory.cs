using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace LetsMeet.Persistence;

public sealed class DesignTimeLetsMeetDbContextFactory : IDesignTimeDbContextFactory<LetsMeetDbContext>
{
    public LetsMeetDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json")
            .Build();
        
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        
        var optionsBuilder = new DbContextOptionsBuilder<LetsMeetDbContext>();
        
        optionsBuilder.UseNpgsql(connectionString);

        return new LetsMeetDbContext(optionsBuilder.Options);
    }
}