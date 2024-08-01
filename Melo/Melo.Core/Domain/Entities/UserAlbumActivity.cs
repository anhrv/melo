using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class UserAlbumActivity
{
    public Guid UserId { get; set; }

    public Guid AlbumId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? Count { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
