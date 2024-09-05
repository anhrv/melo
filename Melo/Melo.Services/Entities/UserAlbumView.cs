using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class UserAlbumView
{
    public int UserId { get; set; }

    public int AlbumId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? Count { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
