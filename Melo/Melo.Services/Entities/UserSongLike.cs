using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class UserSongLike
{
    public int UserId { get; set; }

    public int SongId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Song Song { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
