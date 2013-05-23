/**
 * subscription.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Subscription : Granite.Widgets.LightWindow
{
    public signal void saved (int id, int folder, string name, string url);
    internal Gtk.Button favicon;
    private Gtk.Box button_box;
    private int id;
	private Gtk.ComboBoxText folder;
	private Gtk.Entry channel;
	private Gtk.Entry uri;

	public Subscription ()
	{
		this.title = _("Add new subscription");
        this.window_position = Gtk.WindowPosition.CENTER;
        this.type_hint = Gdk.WindowTypeHint.DIALOG;
		this.set_modal (false);
		this.destroy_with_parent = true;
        this.set_size_request (360, -1);
		this.resizable = false;
        this.id = 0;
		this.folder = new Gtk.ComboBoxText ();
        this.channel = new Gtk.Entry ();
        this.uri = new Gtk.Entry ();

        var save = new Gtk.Button.from_stock (Gtk.Stock.SAVE);
        save.set_size_request (85, -1);
        save.valign = save.halign = Gtk.Align.END;
        save.clicked.connect_after (() =>
        {
	        saved (this.id, this.folder.get_active () + 1, this.channel.get_text (), this.uri.get_text ());
    	    this.destroy ();
        });

        this.favicon = new Gtk.Button.with_label (_("Load favicon"));
        this.favicon.valign = this.favicon.halign = Gtk.Align.START;

        this.button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        this.button_box.pack_end (save, false, false, 0);
        this.button_box.margin_top = 30;

        var f_label = new Gtk.Label ("");
        f_label.set_markup ("<b>%s</b>".printf (_("Folder")));
        f_label.set_halign (Gtk.Align.START);
        var n_label = new Gtk.Label ("");
        n_label.set_markup ("<b>%s</b>".printf (_("Name")));
        n_label.set_halign (Gtk.Align.START);
        n_label.margin_top = 5;
        var u_label = new Gtk.Label ("");
        u_label.set_markup ("<b>%s</b>".printf (_("URI Address")));
        u_label.set_halign (Gtk.Align.START);
        u_label.margin_top = 5;
        
        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content.border_width = 10;
        content.pack_start (f_label);
        content.pack_start (folder, false, true, 0);
        content.pack_start (n_label);
        content.pack_start (channel, false, true, 0);
        content.pack_start (u_label);
        content.pack_start (uri, false, true, 0);
        content.pack_end (button_box, false, false, 0);
        
		this.add (content);
		this.show_all ();
    }
    
    public void add_folder (int folder_id, string folder_name)
    {
		this.folder.append (folder_id.to_string (), folder_name);
		this.folder.set_active (0);
	}

    public void set_model (int id, string title, string uri, int folder)
    {
		this.title = _("Edit subscription %s").printf (title);
        this.id = id;
		this.channel.set_text (title);
		this.uri.set_text (uri);
        this.folder.set_active_id (folder.to_string ());
        this.button_box.pack_start (favicon, false, false, 0);
    }
}
