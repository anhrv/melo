using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class UserSongLike
{
    public Guid UserId { get; set; }

    public Guid SongId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Song Song { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
