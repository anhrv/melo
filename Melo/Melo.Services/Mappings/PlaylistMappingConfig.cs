using Mapster;
using Melo.Models;
using Melo.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Services.Mappings
{
	public class PlaylistMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Playlist, PlaylistResponse>()
				.Map(dest => dest.Songs,
					 src => src.SongPlaylists.Select(sp => sp.Song.Adapt<SongResponse>()));

			config.NewConfig<PlaylistUpsert, Playlist>()
				.PreserveReference(true);
		}
	}
}
