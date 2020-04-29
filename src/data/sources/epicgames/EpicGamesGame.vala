using Gee;
using GameHub.Data.DB;
using GameHub.Utils;

namespace GameHub.Data.Sources.EpicGames
{
	public class EpicGamesGame: Game
	{
		public EpicGamesGame(EpicGames src, string name, string id)
		{
			this.name = name;
			this.id = id;
			platforms.add(Platform.WINDOWS);
		}


		public override async void install(Runnable.Installer.InstallMode install_mode=Runnable.Installer.InstallMode.INTERACTIVE)
		{

		}
		public override async void uninstall()
		{
		}

	}
}
