/**
 * cardlayout.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.ViewAlert : Gtk.EventBox
{
    public string title
	{
        get { return title_label.get_label (); }
        set { title_label.set_label (value); }
    }

    public string subtitle
	{
        get { return subtitle_label.get_label (); }
        set { subtitle_label.set_label (value); }
    }

    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;

	public ViewAlert (string title_text, string subtitle_text)
	{
        title_label = new Gtk.Label (title_text);
        Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H1, title_label);
        title_label.set_justify (Gtk.Justification.CENTER);

        subtitle_label = new Gtk.Label (subtitle_text);
        Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, subtitle_label);
        subtitle_label.sensitive = false;
        subtitle_label.set_justify (Gtk.Justification.CENTER);

        Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content.homogeneous = false;
		content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);
		content.pack_start (title_label, false, true, 0);
		content.pack_start (subtitle_label, false, true, 2);
        content.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

		this.get_style_context ().add_class (Granite.StyleClass.CONTENT_VIEW);
        this.add (content);
    }
}

public enum Feedler.Views
{
	WELCOME = -1, ALERT = 0, LIST = 1, WEB = 2, COLUMN = 3;
}
 
public class Feedler.Layout : Gtk.Notebook
{
    internal Feedler.ViewList list;
    internal Feedler.ViewWeb web;
    internal Granite.Widgets.Welcome welcome;
	internal Feedler.ViewAlert alert;

	construct
	{
		this.show_tabs = false;
		this.show_border = false;
        this.border_width = 0;
	}

    public void init_welcome ()
    {
        this.welcome = new Granite.Widgets.Welcome (_("Get Some Feeds"), _("Feedler can't seem to find your feeds."));
		this.welcome.append ("document-new", _("Create"), _("Add subscriptions from URL."));
		this.welcome.append ("document-import", _("Import"), _("Add subscriptions from OPML file."));
        this.append_page (welcome, null);
    }

    public void init_views ()
    {
		this.alert = new Feedler.ViewAlert (_("No Feeds"), _("Can't seem to find any feeds."));
        this.list = new Feedler.ViewList ();
        this.web = new Feedler.ViewWeb ();
		this.append_page (alert, null);
		this.append_page (list, null);
		this.append_page (web, null);
    }

    public void reinit ()
    {
        this.remove_page (0);
        this.welcome = null;
        //this.init_views ();
    }

	public void display (Feedler.Views view)
	{
		switch (view)
		{
			case Feedler.Views.COLUMN:
				this.list.pane.set_orientation (Gtk.Orientation.HORIZONTAL);
				this.set_current_page (Feedler.Views.LIST);
				break;
			case Feedler.Views.LIST:
				this.list.pane.set_orientation (Gtk.Orientation.VERTICAL);
				this.set_current_page (Feedler.Views.LIST);
				break;			
			default:
				this.set_current_page (view);
				break;
		}
	}
}
