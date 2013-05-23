/**
 * sidebar.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.SidebarItem : Granite.Widgets.SourceList.Item
{
	private Gtk.Menu menu;
	//internal Gtk.MenuItem update;
	internal Gtk.MenuItem mark;
	internal Gtk.MenuItem rename;
	internal Gtk.MenuItem remove;
	internal Gtk.MenuItem edit;

	public SidebarItem (string name, GLib.Icon icon, uint badge = 0, bool menu = false)
	{
		base (name);
		this.editable = true;
		this.icon = icon;
		this.badge = (badge > 0) ? badge.to_string () : null;
		if (menu)
		{
			this.menu = new Gtk.Menu ();
			//this.update = new Gtk.MenuItem.with_label (_("Update"));
			this.mark = new Gtk.MenuItem.with_label (_("Mark as read"));
			this.rename = new Gtk.MenuItem.with_label (_("Rename"));
			this.remove = new Gtk.MenuItem.with_label (_("Remove"));
			this.edit = new Gtk.MenuItem.with_label (_("Edit"));
			//this.menu.append (update);
			this.menu.append (mark);
			this.menu.append (rename);
			this.menu.append (remove);
			this.menu.append (edit);		
			this.menu.show_all ();
		}
	}
	
	public override Gtk.Menu? get_context_menu () {
		if (menu != null) {
			if (menu.get_attach_widget () != null)
				menu.detach ();
			return menu;
		}
		return null;
	}
}

public class Feedler.Sidebar : Granite.Widgets.SourceList
{
	internal Feedler.SidebarItem all;
	internal Feedler.SidebarItem unread;
	internal Feedler.SidebarItem star;

	public Sidebar ()
	{
		//this.init ();
	}

	internal void init ()
	{
		this.all = new Feedler.SidebarItem (_("All items"), Feedler.Icons.ALL);
		this.root.add (all);

		this.unread = new Feedler.SidebarItem (_("Unread items"), Feedler.Icons.UNREAD);
		this.root.add (unread);

		this.star = new Feedler.SidebarItem (_("Starred items"), Feedler.Icons.STAR);
		this.root.add (star);
		
		bool show = !Feedler.SETTING.hide_header;
		this.all.visible = show;
		this.unread.visible = show;
		this.star.visible = show;
	}
}
