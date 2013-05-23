/**
 * folder.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Folder : Granite.Widgets.LightWindow
{
    public signal void saved (int id, string name);
    private int id;
	private Gtk.Entry folder;
	
	public Folder ()
	{
		this.title = _("Add new folder");
        this.window_position = Gtk.WindowPosition.CENTER;
        this.type_hint = Gdk.WindowTypeHint.DIALOG;
		this.set_modal (false);
		this.destroy_with_parent = true;
        this.set_size_request (360, -1);
		this.resizable = false;
        this.id = 0;
		this.folder = new Gtk.Entry ();

        var save = new Gtk.Button.from_stock (Gtk.Stock.SAVE);
        save.set_size_request (85, -1);
        save.valign = save.halign = Gtk.Align.END;
        save.clicked.connect_after (() => { saved (this.id, this.folder.get_text ()); this.destroy (); });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        button_box.pack_end (save, false, false, 0);
        button_box.margin_top = 30;

        var f_label = new Gtk.Label ("");
        f_label.set_markup ("<b>%s</b>".printf (_("Name")));
        f_label.set_halign (Gtk.Align.START);
        
        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content.border_width = 10;
        content.pack_start (f_label);
        content.pack_start (folder, false, true, 0);
        content.pack_end (button_box, false, false, 0);
        
		this.add (content);
		this.show_all ();
    }
    
    public void set_model (int id, string title)
    {
		this.title = _("Edit folder %s").printf (title);
        this.id = id;
		this.folder.set_text (title);
    }
}
