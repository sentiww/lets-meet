using System.IdentityModel.Tokens.Jwt;
using System.Text;
using LetsMeet.Persistence;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Endpoints;
using LetsMeet.WebAPI.Extensions;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using LetsMeet.WebAPI.Options;
using LetsMeet.WebAPI.Services.ApplicationConfigurationService;
using LetsMeet.WebAPI.Services.AssetService;
using LetsMeet.WebAPI.Services.BlobStore;
using LetsMeet.WebAPI.Services.TokenService;
using LetsMeet.WebAPI.Services.UserService;
using LetsMeet.WebAPI.Validators;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Scalar.AspNetCore;
using AuthenticationService = LetsMeet.WebAPI.Services.AuthenticationService.AuthenticationService;
using IAuthenticationService = LetsMeet.WebAPI.Services.AuthenticationService.IAuthenticationService;
using ScalarOptions = LetsMeet.WebAPI.Options.ScalarOptions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
});

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyHeader();
        policy.AllowAnyMethod();
        policy.AllowAnyOrigin();
    });
});

builder.Services.AddOptions<JwtOptions>()
    .BindConfiguration(JwtOptions.SectionName);
builder.Services.AddOptions<AdminOptions>()
    .BindConfiguration(AdminOptions.SectionName);
builder.Services.AddOptions<ScalarOptions>()
    .BindConfiguration(ScalarOptions.SectionName);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    var jwtOptionsSection = builder.Configuration.GetRequiredSection(JwtOptions.SectionName);
    
    var securityKey = jwtOptionsSection.GetRequiredValue<string>(nameof(JwtOptions.SecurityKey));
    var validIssuer = jwtOptionsSection.GetRequiredValue<string>(nameof(JwtOptions.ValidIssuer));
    var validAudience = jwtOptionsSection.GetRequiredValue<string>(nameof(JwtOptions.ValidAudience));
    
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = validIssuer,
        ValidAudience = validAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(securityKey))
    };
});
builder.Services.AddAuthorization();

builder.Services.AddSingleton<ITokenService, TokenService>();
builder.Services.AddSingleton<IAuthenticationService, AuthenticationService>();
builder.Services.AddSingleton<JwtSecurityTokenHandler>();
builder.Services.AddSingleton<IUserService, UserService>();
builder.Services.AddSingleton<IAssetService, AssemblyAssetService>();
builder.Services.AddScoped<IBlobStore, DatabaseBlobStore>();

builder.Services.AddScoped<IApiValidator<SignUpRequest>, SignUpRequestValidator>();
builder.Services.AddScoped<IApiValidator<SignInRequest>, SignInRequestValidator>();
builder.Services.AddScoped<IApiValidator<RefreshTokenRequest>, RefreshTokenRequestValidator>();

builder.Services.AddUserResolver();

builder.Services.AddDbContext<LetsMeetDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseNpgsql(connectionString);
});

builder.Services.AddHostedService<ApplicationConfigurationService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference((options, context) =>
    {
        var scalarOptions = context.RequestServices.GetRequiredService<IOptions<ScalarOptions>>();
        if (scalarOptions.Value.UseHostNetwork)
        {
            options.Servers =
            [
                new("http://localhost:8080")
            ];
        }
        options.WithPreferredScheme(JwtBearerDefaults.AuthenticationScheme)
            .WithDefaultHttpBearerAuthentication(context);
    });
}
app.UseHttpsRedirection();

app.UseCors();

app.UseAuthentication();
app.UseAuthorization();

app.UseUserResolver();

app.MapEndpoints();

app.Run();

internal sealed class BearerSecuritySchemeTransformer(IAuthenticationSchemeProvider authenticationSchemeProvider) : IOpenApiDocumentTransformer
{
    public async Task TransformAsync(OpenApiDocument document, OpenApiDocumentTransformerContext context, CancellationToken cancellationToken)
    {
        var authenticationSchemes = await authenticationSchemeProvider.GetAllSchemesAsync();
        if (authenticationSchemes.Any(authScheme => authScheme.Name == JwtBearerDefaults.AuthenticationScheme))
        {
            var requirements = new Dictionary<string, OpenApiSecurityScheme>
            {
                ["Bearer"] = new OpenApiSecurityScheme
                {
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer", // "bearer" refers to the header name here
                    In = ParameterLocation.Header,
                    BearerFormat = "Json Web Token"
                }
            };
            document.Components ??= new OpenApiComponents();
            document.Components.SecuritySchemes = requirements;
        }
    }
}