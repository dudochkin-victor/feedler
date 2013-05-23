/**
 * toolbar.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 
public class Progress : Gtk.VBox
{
	private Gtk.ProgressBar bar;
	private Gtk.Label label;
	
	construct
	{
		this.bar = new Gtk.ProgressBar ();
		this.label = new Gtk.Label (null);
		this.label.set_justify (Gtk.Justification.CENTER);
		this.label.set_single_line_mode (true);
		this.label.ellipsize = Pango.EllipsizeMode.END;
		
		this.pack_start (label, false, false, 0);
		this.pack_end (bar, false, false, 0);
        this.set_no_show_all (true);
       	this.hide ();
	}

	public void show_bar (string text)
	{
		this.label.set_text (text);
		this.set_no_show_all (false);
		this.show_all ();
	}

	public void hide_bar ()
	{
        this.bar.fraction = 0.0;
		this.set_no_show_all (true);
        this.hide ();
	}

	public void proceed (double fraction)
    {
        this.bar.set_fraction (fraction);
    }

}

public class Feedler.Toolbar : Gtk.Toolbar
{
	internal Gtk.ToolButton update = new Gtk.ToolButton.from_stock (Gtk.Stock.REFRESH);

    internal Gtk.Alignment align = new Gtk.Alignment (0.5f, 0.0f, 0.2f, 0.0f);
    internal Progress progress = new Progress ();
    internal Granite.Widgets.ModeButton mode = new Granite.Widgets.ModeButton ();
    internal Granite.Widgets.SearchBar search = new Granite.Widgets.SearchBar (_("Type to Search..."));
    
    internal Granite.Widgets.AppMenu appmenu;
    //internal Feedler.ContractorButton sharemenu;
    internal Gtk.CheckMenuItem sidebar_visible = new Gtk.CheckMenuItem.with_label (_("Sidebar Visible"));
    internal Gtk.CheckMenuItem fullscreen_mode = new Gtk.CheckMenuItem.with_label (_("Fullscreen"));
    internal Gtk.MenuItem preferences = new Gtk.MenuItem.with_label (_("Preferences"));
    
	construct
	{
		this.sidebar_visible.active = true;
        this.get_style_context ().add_class ("primary-toolbar");
		
        Gtk.Menu menu = new Gtk.Menu ();
        menu.append (sidebar_visible);
        menu.append (fullscreen_mode);
        menu.append (new Gtk.SeparatorMenuItem ());
        menu.append (preferences);
        this.appmenu = Feedler.APP.create_appmenu (menu);
        //this.sharemenu = new Feedler.ContractorButton ();
        
        this.mode.append (new Gtk.Image.from_icon_name ("view-list-compact-symbolic", Gtk.IconSize.MENU));
        this.mode.append (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
		this.mode.append (new Gtk.Image.from_icon_name ("view-column-symbolic", Gtk.IconSize.MENU));
		this.align.add (progress);
        Gtk.ToolItem mode_item = new Gtk.ToolItem ();
		mode_item.margin = 5;
        mode_item.add (mode);
        Gtk.ToolItem search_item = new Gtk.ToolItem ();
        search_item.add (search);
		Gtk.ToolItem progress_item = new Gtk.ToolItem ();
		progress_item.set_expand (true);
		progress_item.add (align);

        this.update.tooltip_text = _("Refresh all subscriptions");
        this.appmenu.tooltip_text = _("Menu");
        
		this.add (update);
        this.add (new Gtk.SeparatorToolItem ());
		this.add (mode_item);
        this.add (progress_item);
		this.add (search_item);
		//this.add (sharemenu);
		this.add (appmenu);
	}
	
	public void set_enable (bool state)
	{
		this.update.set_sensitive (state);
        this.search.set_sensitive (state);
        this.mode.set_sensitive (state);
		this.sidebar_visible.set_sensitive (state);
		this.preferences.set_sensitive (state);
		//this.sharemenu.set_sensitive (state);
	}
}
