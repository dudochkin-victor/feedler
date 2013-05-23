/**
 * cardlayout.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 
public class Feedler.CardLayout : Gtk.Notebook
{
    internal Feedler.ViewList list;
    internal Feedler.ViewWeb web;
    internal Granite.Widgets.Welcome welcome;

	construct
	{
		this.show_tabs = false;
		this.show_border = false;
        this.border_width = 0;
	}

    public void init_welcome ()
    {
        this.welcome = new Granite.Widgets.Welcome (_("Get Some Feeds"), _("Feedler can't seem to find your feeds."));
		this.welcome.append ("document-new", _("Create"), _("Add manually subscriptions from URL."));
		this.welcome.append ("document-import", _("Import"), _("Add a subscriptions from OPML file."));
        this.append_page (welcome, null);
    }

    public void init_views ()
    {
        this.list = new Feedler.ViewList ();
        this.web = new Feedler.ViewWeb ();
		this.append_page (list, null);
		this.append_page (web, null);
    }

    public void reinit ()
    {
        this.remove_page (0);
        this.welcome = null;
        this.init_views ();
    }
}

