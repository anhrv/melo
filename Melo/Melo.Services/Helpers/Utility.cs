namespace Melo.Services.Helpers
{
	public static class Utility
	{
		public static string? ConvertToPlaytime(int? playtimeInSeconds)
		{
			if (playtimeInSeconds is not null)
			{
				int playtimeInSecondsInt = (int)playtimeInSeconds;
				int hours = playtimeInSecondsInt / 3600;
				int minutes = (playtimeInSecondsInt % 3600) / 60;
				int seconds = playtimeInSecondsInt % 60;

				if (hours > 0)
				{
					return $"{hours}:{minutes:D2}:{seconds:D2}";
				}
				else
				{
					return $"{minutes}:{seconds:D2}";
				}
			}

			return null;
		}

		public static int ConvertToSeconds(string timeString)
		{
			var parts = timeString.Split(':');

			int hours = 0;
			int minutes;
			int seconds;

			if (parts.Length == 3)
			{
				hours = int.Parse(parts[0]);
				minutes = int.Parse(parts[1]);
				seconds = int.Parse(parts[2]);
			}
			else if (parts.Length == 2)
			{
				minutes = int.Parse(parts[0]);
				seconds = int.Parse(parts[1]);
			}
			else
			{
				throw new Exception("Invalid time format.");
			}

			return hours * 3600 + minutes * 60 + seconds;
		}
	}
}
