/**
 * dock.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Dock : GLib.Object
{
	private Unity.LauncherEntry dock;

	construct
	{
		this.dock = Unity.LauncherEntry.get_for_desktop_id ("feedler.desktop");
	    this.dock.count_visible = false;
		this.dock.progress_visible = false;
		//this.dock.urgent = true;
	}

	public void counter (uint count)
	{
		this.dock.count = count;
		if (count > 0)
			this.dock.count_visible = true;
		else
			this.dock.count_visible = false;
	}

	public void proceed (double fraction)
	{
		this.dock.progress = fraction;
		if (fraction > 0.0 && fraction < 1.0)
			this.dock.progress_visible = true;
		else
			this.dock.progress_visible = false;
	}
}
