using Gee;
using GameHub.Data.DB;
using GameHub.Utils;

namespace GameHub.Data.Sources.EpicGames
{
	public class EpicGamesGame: Game
	{
		public EpicGamesGame(EpicGames src, string nameP, string idP)
		{
			source = src;
			name = nameP;
			id = idP;
			icon = "";
			platforms.add(Platform.WINDOWS);
			update_status();
		}

		public override void update_status()
		{
			if(status.state == Game.State.DOWNLOADING && status.download.status.state != Downloader.Download.State.CANCELLED) return;

			status = new Game.Status(executable != null && executable.query_exists() ? Game.State.INSTALLED : Game.State.UNINSTALLED, this);
			if(status.state == Game.State.INSTALLED)
			{
				remove_tag(Tables.Tags.BUILTIN_UNINSTALLED);
				add_tag(Tables.Tags.BUILTIN_INSTALLED);
			}
			else
			{
				add_tag(Tables.Tags.BUILTIN_UNINSTALLED);
				remove_tag(Tables.Tags.BUILTIN_INSTALLED);
			}

			installers_dir = FSUtils.file(FSUtils.Paths.Collection.Humble.expand_installers(name));

			update_version();
		}

		public override async void install(Runnable.Installer.InstallMode install_mode=Runnable.Installer.InstallMode.INTERACTIVE)
		{

		}
		public override async void uninstall()
		{
		}

	}
}
