/**
 * settings.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Settings : Granite.Services.Settings
{
	public bool auto_update { get; set; }
	public bool start_update { get; set; }
	public int update_time { get; set; }
	public string[] uri { get; set; }

	public Settings ()
	{
		base ("org.elementary.feedler.service");
	}

	public void add_uri (string u)
	{
		if (u in uri)
			return;

		string[] tmp = this.uri;
		tmp += u;
		this.uri = tmp;
	}
}
