using Gee;

namespace GameHub.Data.Sources.EpicGames
{
	public struct LegendaryGame {
		string name;
		string id;
		string version;
	}

	public class LegendaryWrapper
	{
		private Regex regex = /\*\s*([^(]*)\s\(App\sname:\s([a-zA-Z0-9]+),\sversion:\s([^)]*)\)/;

		public LegendaryWrapper()
		{
		}

		public ArrayList<LegendaryGame?> getGames() {
			var result = new ArrayList<LegendaryGame?>();

			string? line = null;
			MatchInfo info;
			var output = new DataInputStream(new Subprocess.newv ({"legendary", "list-games"}, STDOUT_PIPE).get_stdout_pipe ());

			while ((line = output.read_line()) != null) {
				if (regex.match (line, 0, out info)) {
					LegendaryGame? g = {info.fetch (1),  info.fetch (2),  info.fetch (3)};
					result.add(g);
				}
			}
			return result;
		}

		public void install(string id)
		{
			// FIXME: It can be done much better
			var process = new Subprocess.newv ({"legendary", "download", id}, STDOUT_PIPE | STDIN_PIPE);
			var input = new DataOutputStream(process.get_stdin_pipe ());
			var output = new DataInputStream(process.get_stdout_pipe ());
			string? line = null;
			input.put_string("y\n");
			while ((line = output.read_line()) != null) {
				debug("[EpicGames] %s", line);
			}
			refresh_installed = true;
		}

		public void uninstall(string id)
		{
			// FIXME: It can be done much better
			var process = new Subprocess.newv ({"legendary", "uninstall", id}, STDOUT_PIPE | STDIN_PIPE);
			var input = new DataOutputStream(process.get_stdin_pipe ());
			var output = new DataInputStream(process.get_stdout_pipe ());
			string? line = null;
			input.put_string("y\n");
			while ((line = output.read_line()) != null) {
				debug("[EpicGames] %s", line);
			}
			refresh_installed = true;
		}

		public void run(string id) {
			// FIXME: not good idea
			new Subprocess.newv ({"legendary", "launch", id}, STDOUT_PIPE);
		}

		private bool refresh_installed = true;
		private ArrayList<string> _installed = new ArrayList<string>();

		public bool is_installed(string id)
		{
			if(refresh_installed) {
				build_installed_list();
				refresh_installed = false;
			}
			return _installed.contains(id);
		}


		private void build_installed_list()
		{
			var installed_output = new DataInputStream(new Subprocess.newv ({"legendary", "list-installed"}, STDOUT_PIPE).get_stdout_pipe ());
			_installed.clear();
			string? line = null;
			MatchInfo info;
			while ((line = installed_output.read_line()) != null) {
				if (regex.match (line, 0, out info)) {
					_installed.add(info.fetch(2));
				}
			}
		}
		
	}
}