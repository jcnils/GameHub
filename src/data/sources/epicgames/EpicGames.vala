/*
This file is part of GameHub.
Copyright (C) 2018-2019 Anatoliy Kashkin

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gee;
using GameHub.Data.DB;
using GameHub.Utils;

namespace GameHub.Data.Sources.EpicGames
{
	public class EpicGames: GameSource
	{
		public static EpicGames instance;

		public override string id { get { return "epicgames"; } }
		public override string name { get { return "EpicGames"; } }
		public override string icon { get { return "source-epicgames-symbolic"; } }

		private bool enable = true;
		public override bool enabled
		{
			get { return enable; }
			set { enable = value; }
		}


		public string? user_id { get; protected set; }
		public string? user_name { get; protected set; }

		public EpicGames()
		{
			instance = this;
		}

		public override bool is_installed(bool refresh)
		{
			return true;
		}

		public override async bool install()
		{
			return true;
		}

		public override async bool authenticate()
		{
			return true;
		}

		public override bool is_authenticated()
		{
			return true;
		}

		public override bool can_authenticate_automatically()
		{
			return true;
		}

		public async bool refresh_token()
		{
			debug("TEST2");
			return true;
		}

		private ArrayList<Game> _games = new ArrayList<Game>(Game.is_equal);

		public override ArrayList<Game> games { get { return _games; } }

		public override async ArrayList<Game> load_games(Utils.FutureResult2<Game, bool>? game_loaded=null, Utils.Future? cache_loaded=null)
		{
			debug("[EpicGames] Load games");

			Utils.thread("GOGLoading", () => {
				_games.clear();
				var output = new DataInputStream(new Subprocess.newv ({"legendary", "list-games"}, STDOUT_PIPE).get_stdout_pipe ());
				string? line = null;
				MatchInfo info;
				games_count = 0;
				while ((line = output.read_line()) != null) {
					// FIXME: This REGEX is ugly
					if (/\*\s*([^(]*)\s\(App\sname:\s([a-zA-Z0-9]+),\sversion:\s([^)]*)\)/.match (line, 0, out info)) {
						debug ("\tname = %s\tid = %s\tversion = %s\n\n", info.fetch (1), info.fetch (2), info.fetch (3));
						var g = new EpicGamesGame(this, info.fetch (1),  info.fetch (2));
						
						if(game_loaded != null)
						{
							game_loaded(g, true);
						}
						_games.add(g);
						games_count++;
						g.save();
					}
				}
				Idle.add(load_games.callback);
			});
			yield;
			return _games;
		}


	}
}
