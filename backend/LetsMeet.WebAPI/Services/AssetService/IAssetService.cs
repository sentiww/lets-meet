using Microsoft.Extensions.FileProviders;

namespace LetsMeet.WebAPI.Services.AssetService;

public interface IAssetService
{
    public IFileInfo Get(string name);
}