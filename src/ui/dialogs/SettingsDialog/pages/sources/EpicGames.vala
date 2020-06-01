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

using Gtk;

using GameHub.Utils;
using GameHub.UI.Widgets;

namespace GameHub.UI.Dialogs.SettingsDialog.Pages.Sources
{
	public class EpicGames: SettingsDialogPage
	{
		private Settings.Auth.Epic epic_auth;


		public EpicGames(SettingsDialog dlg)
		{
			Object(
				dialog: dlg,
				title: "EpicGames",
				description: _("Disabled"),
				icon_name: "source-epicgames-symbolic",
				activatable: true
			);
			status = description;
		}

		construct
		{
			var paths = FSUtils.Paths.Settings.instance;
			epic_auth = Settings.Auth.Epic.instance;

			//Legendary Authentication
			legendary_auth();
			adjust_margins(add_labeled_link(_("To authenticate paste the SID code on the field above"), _("Generate code"), "https://www.epicgames.com/id/login?redirectUrl=https%3A%2F%2Fwww.epicgames.com%2Fid%2Fapi%2Fredirect"));

			adjust_margins(add_separator());

			adjust_margins(add_file_chooser(_("Games directory"), FileChooserAction.SELECT_FOLDER, paths.epic_games, v => { paths.epic_games = v; request_restart();  }, false));

			adjust_margins(add_separator());

			status_switch.active = epic_auth.enabled;
			status_switch.notify["active"].connect(() => {
				epic_auth.enabled = status_switch.active;
				update();
				request_restart();
			});



			update();
		}

		private void update()
		{
			var epic = GameHub.Data.Sources.EpicGames.EpicGames.instance;

			content_area.sensitive = epic.enabled;

			if(!epic.enabled)
			{
				status = description = _("Disabled");
			}
			else if(!epic.is_installed())
			{
				status = description = _("Missing Legendary package");
			}
			else if(!epic.is_authenticated())
			{
				status = description = _("Legendary not authenticated");
			}
			else
			{
				status = description = epic.user_name != null ? _("Authenticated as <b>%s</b>").printf(epic.user_name) : _("Authenticated");
			}

		}

		protected void legendary_auth()
		{
			var epic_auth = Settings.Auth.Epic.instance;

			var entry = new Entry();
			entry.max_length = 40;
			if(epic_auth.auth_code != epic_auth.schema.get_default_value("auth-code").get_string())
			{
				entry.text = epic_auth.auth_code;
			}
			entry.primary_icon_name = "source-epicgames-symbolic";
			entry.secondary_icon_name = "edit-delete-symbolic";
			entry.secondary_icon_tooltip_text = _("Clean authentication code");
			entry.set_size_request(280, -1);

			entry.notify["text"].connect(() => { epic_auth.auth_code = entry.text; request_restart(); });
			entry.icon_press.connect((pos, e) => {
				if(pos == EntryIconPosition.SECONDARY)
				{
					entry.text = "";
				}
			});

			var label = new Label(_("Epic Authentication Code"));
			label.halign = Align.START;
			label.hexpand = true;

			var hbox = new Box(Orientation.HORIZONTAL, 12);
			hbox.add(label);
			hbox.add(entry);
			add_widget(hbox);

			adjust_margins(hbox);
		}
		
		private void adjust_margins(Widget w)
		{
			w.margin_start = 16;
			w.margin_end = 12;
		}
	}
}
