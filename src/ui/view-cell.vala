/**
 * view-cell.vala
 * 
 * Based on the work of Lucas Baudin <xapantu@gmail.com>
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.ViewCell : Gtk.CellRenderer
{
    public string subject { set; get; }
    public string author { set; get; }
    public string channel { set; get; }
    public string date { set; get; }
    public bool unread { set; get; }

    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height)
    {
        height = 36;
        width = 250;
		x_offset = 0;
		y_offset = 0;
    }

    public override void render (Cairo.Context cr, Gtk.Widget widget,
                                 Gdk.Rectangle background_area, Gdk.Rectangle area,
                                 Gtk.CellRendererState flags)
    {
        Pango.Layout? layout = null;
        Gtk.StyleContext style = widget.get_style_context ();
        Gdk.RGBA color_subject = style.get_color ((flags & Gtk.CellRendererState.FOCUSED) > 0 ? Gtk.StateFlags.SELECTED : Gtk.StateFlags.NORMAL);
        Gdk.RGBA color_desc = style.get_color ((flags & Gtk.CellRendererState.FOCUSED) > 0 ? Gtk.StateFlags.SELECTED : Gtk.StateFlags.INSENSITIVE);
        Pango.FontDescription font_desc = widget.get_pango_context ().get_font_description ();
        font_desc.set_size (Pango.units_from_double (Pango.units_to_double (font_desc.get_size ()) - 2));
       
        //Subject
        layout = widget.create_pango_layout (subject);
        if (unread)
		{
    	    Pango.FontDescription font_bold = widget.get_pango_context ().get_font_description ();
	        font_bold.set_weight (Pango.Weight.BOLD);
			layout.set_font_description (font_bold);
		}
        layout.set_ellipsize (Pango.EllipsizeMode.END);
        layout.set_width (Pango.units_from_double (area.width - 5));
        cr.move_to (area.x, area.y + 1);
        Gdk.cairo_set_source_rgba (cr, color_subject);
        Pango.cairo_show_layout (cr, layout);
        
        //Description
        layout = widget.create_pango_layout (_("%s, by %s").printf (date, author));
        layout.set_ellipsize (Pango.EllipsizeMode.END);
        layout.set_width (Pango.units_from_double (area.width - 5));
        layout.set_font_description (font_desc);
        cr.move_to (area.x, area.y + 19);
        Gdk.cairo_set_source_rgba (cr, color_desc);
        Pango.cairo_show_layout (cr, layout);
    }
}
