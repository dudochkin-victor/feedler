/**
 * menu.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 

public class Feedler.MenuView : Gtk.Menu
{
    internal Gtk.MenuItem disp = new Gtk.MenuItem.with_label (_("Display"));
    internal Gtk.MenuItem open = new Gtk.MenuItem.with_label (_("Open in browser"));
	internal Gtk.MenuItem copy = new Gtk.MenuItem.with_label (_("Copy URL to clipboard"));
    internal Gtk.MenuItem read = new Gtk.MenuItem.with_label (_("Mark as read"));
	internal Gtk.MenuItem unre = new Gtk.MenuItem.with_label (_("Mark as unread"));
	internal Gtk.MenuItem star = new Gtk.MenuItem.with_label (_("Add to starred"));
	internal Gtk.MenuItem unst = new Gtk.MenuItem.with_label (_("Remove from starred"));
    
	construct
	{
        this.append (disp);
        this.append (open);
        this.append (copy);
        this.append (new Gtk.SeparatorMenuItem ());
        this.append (read);
        this.append (unre);
		this.append (star);
		this.append (unst);
	}

	public void select_mark (bool read, bool starred)
	{
		this.read.set_sensitive (!read);
		this.unre.set_sensitive (read);
		this.star.set_sensitive (!starred);
		this.unst.set_sensitive (starred);
	}
}
