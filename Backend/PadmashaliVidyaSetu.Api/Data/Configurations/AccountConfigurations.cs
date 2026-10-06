using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Entities.Accounts;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class AccountConfiguration : IEntityTypeConfiguration<Account>
{
    public void Configure(EntityTypeBuilder<Account> b)
    {
        b.ToTable("Accounts", t => t.HasCheckConstraint("CK_Accounts_MobileNumber", "[MobileNumber] LIKE '+[1-9]%'"));
        b.HasKey(e => e.AccountId);
        b.Property(e => e.MobileNumber).HasMaxLength(16).IsUnicode(false).IsRequired();
        b.HasIndex(e => e.MobileNumber).IsUnique();
        b.Property(e => e.MobileVerifiedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.LastLoginDate).HasColumnType("datetime2(3)");
        b.ConfigureAudit();
    }
}

public class AccountRoleConfiguration : IEntityTypeConfiguration<AccountRole>
{
    public void Configure(EntityTypeBuilder<AccountRole> b)
    {
        b.ToTable("AccountRoles");
        b.HasKey(e => new { e.AccountId, e.RoleId });
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.CreatedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasOne(e => e.Account).WithMany(a => a.AccountRoles).HasForeignKey(e => e.AccountId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.Role).WithMany().HasForeignKey(e => e.RoleId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> b)
    {
        b.ToTable("RefreshTokens");
        b.HasKey(e => e.RefreshTokenId);
        b.Property(e => e.TokenHash).HasMaxLength(64).IsFixedLength().IsUnicode(false).IsRequired();
        b.HasIndex(e => e.TokenHash).IsUnique();
        b.Property(e => e.ReplacedByTokenHash).HasMaxLength(64).IsFixedLength().IsUnicode(false);
        b.Property(e => e.CreatedByIp).HasMaxLength(45).IsUnicode(false);
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.ExpiresDate).HasColumnType("datetime2(3)");
        b.Property(e => e.RevokedDate).HasColumnType("datetime2(3)");
        b.HasIndex(e => e.AccountId);
        b.HasOne(e => e.Account).WithMany().HasForeignKey(e => e.AccountId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class PhoneVerificationChallengeConfiguration : IEntityTypeConfiguration<PhoneVerificationChallenge>
{
    public void Configure(EntityTypeBuilder<PhoneVerificationChallenge> b)
    {
        b.ToTable("PhoneVerificationChallenges");
        b.HasKey(e => e.ChallengeId);
        b.Property(e => e.MobileNumber).HasMaxLength(16).IsUnicode(false).IsRequired();
        b.Property(e => e.CodeHash).HasMaxLength(64).IsFixedLength().IsUnicode(false).IsRequired();
        b.Property(e => e.RequestIp).HasMaxLength(45).IsUnicode(false);
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.ExpiresDate).HasColumnType("datetime2(3)");
        b.Property(e => e.VerifiedDate).HasColumnType("datetime2(3)");
        // Supports the per-number send-rate check.
        b.HasIndex(e => new { e.MobileNumber, e.CreatedDate });
    }
}
