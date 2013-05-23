/**
 * manager.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Feedler.Manager : GLib.Object
{
	internal int count;
	internal int news;
	private int steps;
	private double fraction;
	private double proceed;
	private Feedler.Dock dockbar;
	private Feedler.Indicator indicator;
	private Feedler.Window window;
	internal GLib.List<Serializer.Folder?> folders;

	public Manager (Feedler.Window win)
	{
		this.dockbar = new Feedler.Dock ();
		this.indicator = new Feedler.Indicator ();
		this.window = win;
	}

	public void unread (int diff = 0)
	{
		this.count += diff;
		this.dockbar.counter (count);
		this.indicator.counter (count);
		this.window.side.unread.badge = count.to_string ();
		this.window.stat.counter (count);
	}

	public void begin (string text, int steps = 1)
	{
		this.window.toolbar.progress.show_bar (text);
		this.steps = steps;
		//this.fraction = 1.0 / (steps * 2.0);
		this.fraction = 1.0 / (steps + 1.0);
		this.news = 0;
		this.proceed = 0.0;
		this.progress ();
	}

	public void progress ()
	{
		this.proceed += fraction;
		if (this.proceed > 1.0)
			this.proceed = 1.0;
		this.window.toolbar.progress.proceed (proceed);
		this.dockbar.proceed (proceed);
	}

	public bool end (string? msg = null)
	{
		this.steps--;
		this.progress ();
		if (steps == 0)
        {
            this.window.toolbar.progress.hide_bar ();
			this.dockbar.proceed (1.0);
			this.unread ();
			return true;
        }
		return false;
	}

	public void error ()
	{
		this.steps = 0;
        this.window.toolbar.progress.hide_bar ();
		this.dockbar.proceed (1.0);
	}

	public async void update (Serializer.Channel channel)
	{
		GLib.SourceFunc callback = update.callback;
		if (channel.source == null)
		{
			stderr.printf ("Blad podczas parsowania");
			yield;
			return;
		}

		GLib.ThreadFunc<void*> update_func = () =>
		{
		    unowned Model.Channel ch = this.window.db.get_channel_from_source (channel.source);
			if (ch != null)
			{
				GLib.List<Serializer.Item?> reverse = new GLib.List<Serializer.Item?> ();
				string last = ch.last_item_title ();
				foreach (var i in channel.items)
				{
				    if (last == i.title)
				        break;
				    reverse.append (i);
				}
				reverse.reverse ();
				this.window.db.begin ();
				foreach (var i in reverse)
				{
				    int id = this.window.db.insert_item (ch.id, i);
				    Model.Item it = new Model.Item.with_data (id, i.title, i.source, i.author, i.description, i.time, ch);
				    ch.items.append ((owned)it);
				}
				this.window.db.commit ();
				if (reverse.length () > 0)
				{
					int length = int.parse (reverse.length ().to_string ());
					this.count += length;
					this.news += length;
					this.window.channel_mark_update (ch.title, length);
				}
			} else
				stderr.printf ("Source not exist in database %s\n", channel.source);
			/*if (this.end ())
				this.window.notification ("%i %s".printf (news, news > 1 ? _("new feeds") : _("new feed")));*/
        	Idle.add ((owned)callback);
        	return null;
    	};

		try
		{
			GLib.Thread<void*> thread_update = new GLib.Thread<void*>.try ("thread_update", update_func);
		}
		catch (GLib.Error e)
		{
			stderr.printf ("Cannot run update threads.\n");
		}
		yield;
	}

	public async void import (Serializer.Folder[] folders)
	{
		// Cannot modify GTK Widgets from other Threads (it makes random crashes)
		GLib.SourceFunc callback = import.callback;
		//FIXME IF YOU CAN - from list thread can get data, but from array cannot
		this.folders = new GLib.List<Serializer.Folder?> ();
		foreach (Serializer.Folder folder in folders)
			this.folders.append (folder);

		GLib.ThreadFunc<void*> import_func = () =>
		{
			//int count = 0;
			this.news = 0;
			int folder_id = (this.window.db.select_max ("folders")) + 1;
			int channel_id = (this.window.db.select_max ("channels")) + 1;
			this.window.db.begin ();
			foreach (Serializer.Folder f in this.folders)
			{
				this.window.db.insert_folder (f);
			    Model.Folder fo = new Model.Folder.with_data (folder_id, f.name);
			    this.news += f.channels.length;
			    foreach (Serializer.Channel c in f.channels)
			    {
					this.window.db.insert_channel (folder_id, c);
					Model.Channel ch = new Model.Channel.with_data (channel_id, c.title, c.link, c.source, fo);
					fo.channels.append ((owned)ch);
					channel_id++;
			    }
				this.window.db.data.append ((owned)fo);
				folder_id++;
			}
			this.window.db.commit ();
			/*if (this.end ())
				this.window.notification (_("Imported %i channels in %i folders.").printf (count, this.folders.length ()));*/
        	Idle.add ((owned)callback);
        	return null;
    	};
		try
		{
			GLib.Thread<void*> thread_import = new GLib.Thread<void*>.try ("thread_import", import_func);
		}
		catch (GLib.Error e)
		{
			stderr.printf ("Cannot run import threads.\n");
		}
    	yield;
	}
}

/*public class Feedler.Stopwatch
{
	internal List<TimeVal?> times;
	internal List<string?> descs;

	public Stopwatch ()
	{
		this.times = new List<TimeVal?>();
	}

	public void step (string? description = null)
	{
		var step = TimeVal ();
		step.get_current_time ();
		this.times.append (step);
		this.descs.append (description);
	}

	public void to_string ()
	{
		for (uint i = 0; i < this.times.length (); i++)
			stdout.printf ("%s - %s\n", this.times.nth_data (i).to_iso8601 (), this.descs.nth_data (i));
	}
}*/
