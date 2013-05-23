/**
 * contractor.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

[DBus (name = "org.elementary.contractor")]
public interface Feedler.Contractor : GLib.Object
{
	public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime="text/xml") throws IOError;
}

public class Feedler.ContractorButton : Granite.Widgets.ToolButtonWithMenu
{
	internal Gtk.MenuItem export;
	private Feedler.Contractor contract;
	private GLib.HashTable<string,string>[] services;
	private GLib.List<Gtk.MenuItem> items;

	public ContractorButton ()
	{
	    base (new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.MENU), _("Share channels or items"), new Gtk.Menu ());
		this.items = new GLib.List<Gtk.MenuItem> ();
	    try
		{
			contract = Bus.get_proxy_sync (BusType.SESSION, "org.elementary.contractor",
															"/org/elementary/contractor");

			services = contract.GetServicesByLocation (GLib.Environment.get_tmp_dir () + "/feedler.html");
			foreach (GLib.HashTable<string,string> service in services)
			{
				Gtk.MenuItem item = new Gtk.MenuItem.with_label (service.lookup ("Description"));
				item.activate.connect (activate_contract);
				menu.append (item);
				items.append (item);
			}
		    this.export = new Gtk.MenuItem.with_label(_("Export subscriptions"));
		    menu.append (export);
	    }
		catch (IOError e)
		{
			stderr.printf ("%s\n", e.message);
	    }

	}

	public void switch_state (bool state)
	{
		foreach (var item in items)
			item.set_sensitive (state);
	}

	private void activate_contract ()
	{
		Gtk.MenuItem menuitem = (Gtk.MenuItem) menu.get_active ();
		string app_menu = menuitem.get_label ();
		foreach (HashTable<string,string> service in services)
		{
			if (app_menu == service.lookup ("Description"))
			{
				try
				{
					GLib.Process.spawn_command_line_async (service.lookup ("Exec"));
				}
				catch (GLib.SpawnError e)
				{
					warning (e.message);
				}
				break;
			}
		}
	}
}