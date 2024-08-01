using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class UserArtistActivity
{
    public Guid UserId { get; set; }

    public Guid ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? Count { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
