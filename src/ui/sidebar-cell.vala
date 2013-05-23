/**
 * sidebar-cell.vala
 * 
 * Based on the work of Lucas Baudin <xapantu@gmail.com>
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.SidebarCell : Gtk.CellRenderer
{
	public static string location = GLib.Environment.get_user_data_dir () + "/feedler/fav/";	
	public enum Type { FOLDER, CHANNEL, ERROR; }
	public int id { set; get; }
	public string channel { set; get; }
	public int unread { set; get; }
	public Type type;
	
	double height_centered;

	static void rounded (Cairo.Context cr, double x, double y, double w, double h)
	{
		double radius = GLib.Math.fmin (w/2.0, h/2.0);

		cr.move_to (x+radius, y);
		cr.arc (x+w-radius, y+radius, radius, GLib.Math.PI*1.5, GLib.Math.PI*2);
		cr.arc (x+w-radius, y+h-radius, radius, 0, GLib.Math.PI*0.5);
		cr.arc (x+radius,   y+h-radius, radius, GLib.Math.PI*0.5, GLib.Math.PI);	
		cr.arc (x+radius,   y+radius,   radius, GLib.Math.PI, GLib.Math.PI*1.5);
	}

    static double get_layout_width (Pango.Layout layout)
    {
        Pango.Rectangle rect = Pango.Rectangle ();
        layout.get_extents (out rect, null);
        return Pango.units_to_double (rect.width);
    }

    static double get_layout_height (Pango.Layout layout)
    {
        Pango.Rectangle rect = Pango.Rectangle();
        layout.get_extents(out rect, null);
        return Pango.units_to_double (rect.height);
    }

    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height)
    {
        height = 22;
        width = 250;
		x_offset = 0;
		y_offset = 0;
    }

    public override void render (Cairo.Context cr, Gtk.Widget widget,
                                 Gdk.Rectangle background_area, Gdk.Rectangle area,
                                 Gtk.CellRendererState flags) {
        Pango.Layout? layout = null;
        Gtk.StyleContext style = widget.get_style_context ();
        Gdk.RGBA color_normal = style.get_color ((flags & Gtk.CellRendererState.FOCUSED) > 0 ? Gtk.StateFlags.SELECTED : Gtk.StateFlags.NORMAL);
        Gdk.RGBA color_insensitive = style.get_color (Gtk.StateFlags.INSENSITIVE);
        color_insensitive.alpha = 0.5;
        Gdk.RGBA color_selected = style.get_color (Gtk.StateFlags.SELECTED);
		Gdk.RGBA color_unread = style.get_color (Gtk.StateFlags.ACTIVE);
        Pango.FontDescription font_medium = widget.get_pango_context ().get_font_description ();
        font_medium.set_size (Pango.units_from_double (Pango.units_to_double (font_medium.get_size()) - 2));
        Pango.FontDescription font_bold = widget.get_pango_context ().get_font_description ();
        font_bold.set_weight (Pango.Weight.BOLD);
		
		double margin = 5.0;
		height_centered = area.y + 4;
		
        /* unread */
        if (unread > 0)
        {
            layout = widget.create_pango_layout (unread.to_string ());
			layout.set_font_description (font_bold);
            double rect_width = get_layout_width (layout) + margin * 2;
            double rect_height = get_layout_height (layout) + margin * 2;
            /* Background */
            rounded (cr, area.width, height_centered-2, rect_width, rect_height);
            Gdk.cairo_set_source_rgba (cr, color_unread);
            cr.fill ();
            /* Real text */
            cr.move_to (area.width + margin, height_centered-1);
            Gdk.cairo_set_source_rgba (cr, color_selected);
            Pango.cairo_show_layout (cr, layout);
		}
		
		/* Channel */
        layout = widget.create_pango_layout (channel);
        if (type == Type.FOLDER)
        {
			layout.set_font_description (font_bold);
			cr.move_to (area.x + 5, height_centered);
		}
		else
			cr.move_to (area.x + 12, height_centered);
        layout.set_ellipsize (Pango.EllipsizeMode.END);
        layout.set_width (Pango.units_from_double (area.width - margin));
        Gdk.cairo_set_source_rgba (cr, color_normal);
        Pango.cairo_show_layout (cr, layout);
        
        /* Icon */
        if (type == Type.ERROR)
        {
			weak Gdk.Pixbuf pix = new Gtk.Invisible ().render_icon_pixbuf (Gtk.Stock.CANCEL, Gtk.IconSize.MENU);
			Gdk.cairo_set_source_pixbuf (cr, pix, area.x - 8, height_centered - 1);
			cr.paint ();
		}
        else if (type == Type.CHANNEL)
        {
            string png = "%s%i.png".printf (location, id);
            if (GLib.FileUtils.test (png, GLib.FileTest.EXISTS))
		    {
			    cr.set_source_surface (new Cairo.ImageSurface.from_png (png), area.x - 8, height_centered);
			    cr.paint ();
		    }
            else
            {
                try
                {
                    Gtk.IconTheme icons = Gtk.IconTheme.get_default ();
                    Gdk.Pixbuf pix = icons.load_icon ("internet-news-reader", 16, 0);
                    Gdk.cairo_set_source_pixbuf (cr, pix, area.x - 8, height_centered - 1);
        			cr.paint ();
                }
                catch (GLib.Error e)
                {
                    stderr.printf ("ERROR: %s - No such file found for: internet-news-reader\n", e.message);
                }
            }
        }
    }
}
