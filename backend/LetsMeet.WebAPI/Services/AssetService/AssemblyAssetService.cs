using System.Reflection;
using Microsoft.Extensions.FileProviders;

namespace LetsMeet.WebAPI.Services.AssetService;

internal sealed class AssemblyAssetService : IAssetService
{
    private const string BasePath = "Assets";
    
    private readonly EmbeddedFileProvider _embeddedFileProvider;

    public AssemblyAssetService()
    {
        var assembly = Assembly.GetExecutingAssembly();
        _embeddedFileProvider = new EmbeddedFileProvider(assembly);
    }

    public IFileInfo Get(string name)
    {
        return _embeddedFileProvider.GetFileInfo($"{BasePath}/{name}");
    }
}