using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class UserSongView
{
    public int UserId { get; set; }

    public int SongId { get; set; }

    public DateTime? CreatedAt { get; set; }

	public DateTime? ModifiedAt { get; set; }

	public int? Count { get; set; }

    public virtual Song Song { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
