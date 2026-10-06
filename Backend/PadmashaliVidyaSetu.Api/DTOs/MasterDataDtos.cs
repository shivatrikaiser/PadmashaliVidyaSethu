namespace PadmashaliVidyaSetu.Api.DTOs;

public sealed record MasterDataItemDto(int Id, string Name, string Code);

public sealed record LocalityDto(int CityId, string Name, int? TalukId);

public sealed record PinCodeLookupResponse(
    string PinCode,
    MasterDataItemDto Country,
    MasterDataItemDto State,
    MasterDataItemDto District,
    IReadOnlyList<LocalityDto> Localities,
    IReadOnlyList<MasterDataItemDto> Taluks,
    int? SuggestedTalukId);
