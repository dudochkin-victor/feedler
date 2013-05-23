/**
 * view-web.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 
public class Feedler.ViewWeb : Feedler.View
{
	private WebKit.WebView browser;
	private Gtk.ScrolledWindow scroll_web;
	private GLib.StringBuilder content;

	construct
	{
		this.browser = new WebKit.WebView ();
		this.browser.settings = this.settings;
		
		this.scroll_web = new Gtk.ScrolledWindow (null, null);
		this.scroll_web.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.scroll_web.add (browser);
		this.add (scroll_web);
		
		this.content = new GLib.StringBuilder ();
	}
		
	public override void clear ()
	{
		this.content.assign (generate_style ("rgb(77,77,77)", "rgb(113,113,113)", "rgb(77,77,77)", "rgb(0,136,205)"));
	}
	
	public override void add_feed (Model.Item item, string time_format)
	{
		this.content.prepend (generate_item (item.title, time_format, item.author, item.description));
	}
	
	public override void load_feeds ()
	{
		stderr.printf ("Feedler.ViewWeb.load_feeds ()\n");
		this.browser.load_string (content.str, "text/html", "UTF-8", "");
		//this.item_marked (-1, true);
	}
	
	public override void refilter (string text)
	{
		this.browser.search_text (text, true, true, true);
	}

	public override bool contract ()
	{
		try
		{
			var path = GLib.Environment.get_tmp_dir () + "/feedler.html";
                
            GLib.File file = GLib.File.new_for_path (path);
            uint8[] data = content.data;
            string s;
            file.replace_contents (data, null, false, 0, out s);
            
			return true;
		}
		catch (GLib.Error e)
		{
			stderr.printf ("Cannot create temp file.\n");
		}
		return false;
	}
	
	private string generate_item (string title, string time, string author, string description)
	{
		GLib.StringBuilder item = new GLib.StringBuilder ();
		item.append ("<div class='item'><span class='title'>"+title+"</span><br/>");
		item.append ("<span class='time'>"+time+", by "+author+"</span><br/>");
		item.append ("<span class='content'>"+description+"</span></div><br/>");
		
		return item.str;
	}
}
