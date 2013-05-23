/**
 * indicator.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Indicator : GLib.Object
{
	private Indicate.Server server;
	private Indicate.Indicator update;
	private Indicate.Indicator unread;

	construct
	{
		this.server = Indicate.Server.ref_default ();
    	this.server.set_type ("message.im");
		this.server.set_desktop_file ("/usr/share/applications/feedler.desktop");
    	this.server.server_display.connect (Feedler.APP.switch_display);
    	this.server.show ();

		this.update = new Indicate.Indicator.with_server (server);
		this.update.user_display.connect (Feedler.APP.update);
		this.update.set_property ("name", _("Update"));
		this.update.show ();

		this.unread = new Indicate.Indicator.with_server (server);
		this.unread.set_property ("sender", _("Unread"));
		this.unread.set_property ("count", "0");
	}

	public void counter (uint count)
	{
		this.unread.set_property ("count", count.to_string ());
		if (count > 0)
		{
			this.unread.set_property_bool ("draw-attention", true);
			this.unread.show ();
		}
		else
		{
			this.unread.set_property_bool ("draw-attention", false);
			this.unread.hide ();
		}
	}
}
