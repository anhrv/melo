using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class UserArtistLike
{
    public int UserId { get; set; }

    public int ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
