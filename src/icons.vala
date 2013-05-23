/**
 * icons.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 
public class Feedler.Icons
{
	private static string path = "/usr/share/feedler/icons/%s.%s";

    public static GLib.Icon ALL = new GLib.FileIcon (GLib.File.new_for_path (path.printf ("all", "png")));
	public static GLib.Icon STAR = new GLib.FileIcon (GLib.File.new_for_path (path.printf ("star", "png")));
	public static GLib.Icon UNREAD = new GLib.FileIcon (GLib.File.new_for_path (path.printf ("unread", "png")));
	public static GLib.Icon RSS = new GLib.FileIcon (GLib.File.new_for_path (path.printf ("favicon", "pnh")));
	public static GLib.Icon MARK = new GLib.FileIcon (GLib.File.new_for_path (path.printf ("mark", "svg")));
}
