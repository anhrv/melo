namespace Melo.Files.Helpers
{
	public static class Utility
	{
		public static bool ValidEntityId(int id)
		{
			return id > 0;
		}

		public static bool ValidEntityType(string entityType)
		{
			List<string> acceptableEntityTypes = ["song", "album", "artist", "genre"];

			if (!acceptableEntityTypes.Contains(entityType.ToLower()) || string.IsNullOrWhiteSpace(entityType))
			{
				return false;
			}

			return true;
		}

		public static string CapitalizeFirstLetter(string input)
		{
			if (string.IsNullOrWhiteSpace(input))
				return input;

			return char.ToUpper(input[0]) + input.Substring(1).ToLower();
		}
	}
}
