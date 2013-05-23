/**
 * infobar.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public abstract class Feedler.Task
{
	internal int counter;
	internal string message;
	internal string label;

	public abstract void dismiss ();
	public abstract void undo ();
}

public class Feedler.ConnectedTask : Feedler.Task
{
	public ConnectedTask ()
	{
		this.counter = 3;
		this.message = _("Welcome! You are connected to the service ;-)");
		this.label = _("Close");
	}

	public override void dismiss ()
	{
		// NOTHING
	}

	public override void undo ()
	{
		// NOTHING
	}
}

public class Feedler.ReconnectTask : Feedler.Task
{
	public delegate void DelegateType ();
	public DelegateType function;

	public ReconnectTask (DelegateType try_connect)
	{
		this.function = try_connect;
		this.counter = 3;
		this.message = _("Cannot connect to service ;-(");
		this.label = _("Connect");
	}

	public override void dismiss ()
	{
		this.function ();
	}

	public override void undo ()
	{
		this.function ();
	}
}

public class Feedler.RenameTask : Feedler.Task
{
	private unowned Feedler.Database db;
	private unowned Granite.Widgets.SourceList.Item item;
	private unowned Model.Channel channel;
	private string name;

	public RenameTask (Feedler.Database db, Granite.Widgets.SourceList.Item item, Model.Channel channel, string old_name)
	{
		this.db = db;
		this.item = item;
		this.channel = channel;
		this.counter = 5;
		this.name = old_name;
		this.message = _("Undo rename %s").printf (name);
		this.label = _("Undo");
	}

	public override void dismiss ()
	{
		this.db.rename_channel (name, item.name);
	}

	public override void undo ()
	{
		//Model.Channel c = this.db.get_channel (item.name);
		channel.title = this.name;
		item.name = this.name;
	}
}

public class Feedler.RemoveTask : Feedler.Task
{
	private unowned Feedler.Database db;
	private unowned Granite.Widgets.SourceList.Item item;

	public RemoveTask (Feedler.Database db, Granite.Widgets.SourceList.Item item)
	{
		this.db = db;
		this.item = item;
		this.counter = 5;
		this.message = _("Undo delete %s").printf (item.name);
		this.label = _("Undo");
	}

	public override void dismiss ()
	{
		var i = this.item.parent;
		this.db.remove_channel (item.name);
		i.remove (this.item);		
	}

	public override void undo ()
	{
		this.item.visible = true;
	}
}

public class Feedler.Infobar : Gtk.InfoBar
{
	private Feedler.Task task;
	private Gtk.Label label;
	private Gtk.Label time;
	private Gtk.Button button;
	
	public Infobar ()
	{
		this.set_message_type (Gtk.MessageType.QUESTION);

		this.label = new Gtk.Label ("");
		this.label.set_line_wrap (true);
		this.label.halign = Gtk.Align.START;
		this.label.use_markup = true;

		this.time = new Gtk.Label (null);
		this.time.halign = Gtk.Align.END;
		this.time.set_sensitive (false);

		this.button = new Gtk.Button.with_label (_("Undo"));
		this.button.clicked.connect (undone);
		
		var expander = new Gtk.Label ("");
		expander.hexpand = true;
		
		((Gtk.Box)get_content_area ()).add (label);
		((Gtk.Box)get_content_area ()).add (expander);
		((Gtk.Box)get_content_area ()).add (time);
		((Gtk.Box)get_content_area ()).add (button);
		
		this.no_show_all = true;
		this.hide ();
	}

	public void question (Feedler.Task task)
	{
		this.set_message_type (Gtk.MessageType.QUESTION);
		this.task = task;
		this.label.set_markup (task.message);
		this.button.label = task.label;
		this.prepare ();
	}
	
	public void warning (Feedler.Task task)
	{
		this.set_message_type (Gtk.MessageType.WARNING);
		this.task = task;
		this.label.set_markup (task.message);
		this.button.label = task.label;
		this.prepare ();
	}
	
	public void info (Feedler.Task task)
	{
		this.set_message_type (Gtk.MessageType.INFO);
		this.task = task;
		this.label.set_markup (task.message);
		this.button.label = task.label;
		this.prepare ();
	}
	
	private void prepare ()
	{
		this.time.set_markup (_("<small>Dismiss after %i seconds.</small>").printf (this.task.counter));
		this.no_show_all = false;
		this.show_all ();
		GLib.Timeout.add_seconds (1, () =>
		{
			if (this.task == null)
				return false;
			else if (this.task.counter < 1)
			{
				this.dismiss ();
				return false;
			}
			else
			{
				this.time.set_markup (_("<small>Dismiss after %i seconds.</small>").printf (--this.task.counter));
				return true;
			}
		});
	}

	private void undone ()
	{
		this.task.undo ();
		this.no_show_all = true;
		this.hide ();
		this.task = null;
	}

	private void dismiss ()
	{
		this.task.dismiss ();
		this.no_show_all = true;
		this.hide ();
		this.task = null;
	}
}
