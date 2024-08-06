using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;

namespace Melo.Services
{
	public class GenreService : CRUDService<Genre, GenreResponse, GenreSearchObject, GenreUpsert, GenreUpsert>, IGenreService
	{

		public GenreService(ApplicationDbContext context, IMapper mapper)
		: base(context, mapper)
		{

		}

		public override IQueryable<Genre> AddFilters(GenreSearchObject request, IQueryable<Genre> query)
		{
			query = base.AddFilters(request, query);

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(g => g.Name.Contains(request.Name));
			}

			return query;
		}

		public override void BeforeInsert(GenreUpsert request, Genre entity)
		{
			base.BeforeInsert(request, entity);
			entity.CreatedAt = DateTime.UtcNow;
			//TODO: set CreatedBy
			//TODO: set ImageUrl
			entity.ViewCount = 0;
		}

		public override void BeforeUpdate(GenreUpsert request, Genre entity)
		{
			base.BeforeUpdate(request, entity);
			entity.ModifiedAt = DateTime.UtcNow;
			//TODO: set ModifiedBy
			//TODO: set ImageUrl
		}
	}
}
