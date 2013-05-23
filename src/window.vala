/**
 * window.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
//TODO data/icon dodac w cmake
public class Feedler.Window : Gtk.Window
{
	internal Feedler.Database db;
	internal Feedler.Toolbar toolbar;
	internal Feedler.Infobar infobar;
	internal Feedler.Sidebar side;
	internal Feedler.Statusbar stat;
	private weak Feedler.View view;
	private Granite.Widgets.ThinPaned pane;
	private Gtk.Box content;
	private Feedler.Layout layout;
    private Feedler.Client client;
	private Feedler.Manager manager;

	static construct
	{
		new Feedler.Icons ();
	}
	
	construct
	{
        
		this.db = new Feedler.Database ();
		this.manager = new Feedler.Manager (this);
		this.layout = new Feedler.Layout ();
		this.delete_event.connect (destroy_app);
		this.content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);	
        this.ui_layout ();
        this.set_default_size (Feedler.STATE.window_width, Feedler.STATE.window_height);

		if (this.db.is_created ())
			this.ui_feeds ();
		else
			this.ui_welcome ();		
		
		this.add (content);
		this.try_connect ();
	}
	
	internal void try_connect ()
	{
		try
        {
            client = Bus.get_proxy_sync (BusType.SESSION, "org.example.Feedler",
                                                        "/org/example/feedler");
            /*client.iconed.connect (favicon_cb);
			client.added.connect (added_cb);           
            client.updated.connect (updated_cb);*/
			client.imported.connect ((f) =>
			{
				this.manager.import.begin (f, (o, r) =>
				{
					if (this.manager.end ())
						this.notification (_("Imported %i channels in %i folders.").printf (this.manager.news, this.manager.folders.length ()));
					this.load_sidebar ();
					this.manager.news = 0;
        		});
			});
			client.updated.connect ((c) =>
			{
				this.manager.update.begin (c, (o, r) =>
				{
					if (this.manager.end ())
						this.notification ("%i %s".printf (this.manager.news, (this.manager.news > 1) ? _("new feeds") : _("new feed")));
					//this.load_sidebar ();
					//var result = this.manager.update.end (r);
        		});
			});
			stderr.printf ("%s\n", client.ping ());
			//TODO nie widzi w DBus, chyba nie am czegos aktualnego..
			//Serializer.Folder[] data = client.get_data ();
			
			//this.infobar.info (new Feedler.ConnectedTask ());
        }
        catch (GLib.Error e)
        {
			stderr.printf (e.message);
			this.infobar.warning (new Feedler.ReconnectTask (this.try_connect));
        }
	}
    
    private void ui_layout ()
    {
		this.toolbar = new Feedler.Toolbar ();
		this.toolbar.mode.selected = 0;
		this.content.pack_start (toolbar, false, false, 0);	
		this.toolbar.update.clicked.connect (update_subscription);
        this.toolbar.mode.mode_changed.connect (change_mode);
        this.toolbar.mode.selected = Feedler.STATE.view_mode;
        this.toolbar.search.activate.connect (item_search);
		/*this.toolbar.sharemenu.clicked.connect (() =>
		{
			if (this.view.contract ())
				this.toolbar.sharemenu.switch_state (true);
			else
				this.toolbar.sharemenu.switch_state (false);
		});
        this.toolbar.sharemenu.export.activate.connect (_export);*/
        this.toolbar.preferences.activate.connect (config);
        this.toolbar.sidebar_visible.toggled.connect (sidebar_update);
        this.toolbar.fullscreen_mode.toggled.connect (fullscreen_mode);

		this.infobar = new Feedler.Infobar ();        
        this.content.pack_start (infobar, false, false, 0);

		this.side = new Feedler.Sidebar ();
		this.side.item_selected.connect (channel_selected);
		this.pane = new Granite.Widgets.ThinPaned ();
		this.pane.expand = true;
        this.content.pack_start (pane, true);
		this.pane.pack2 (layout, true, false);
    }

	private void ui_workspace ()
	{
        this.pane.set_position (Feedler.STATE.sidebar_width);
		this.pane.pack1 (side, true, false);
        this.layout.init_views ();
		this.view = (Feedler.View)layout.get_nth_page (1);
		this.layout.list.item_marked.connect (item_mark);
		//this.layout.web.item_marked.connect (item_mark);

        this.stat = new Feedler.Statusbar ();
		this.stat.add_feed.folder.activate.connect (add_folder);
		this.stat.add_feed.subscription.activate.connect (add_subscription);
		this.stat.add_feed.import.activate.connect (import_subscription);
		this.stat.mark_feed.button_press_event.connect ((e) =>
		{
			this.all_mark ();
			return false;
		});
		this.stat.next_feed.button_press_event.connect ((e) =>
		{
			this.item_next ();
			return false;
		});
        this.content.pack_end (this.stat, false, true, 0);
		this.show_all ();
	}
	
	private void ui_feeds ()
	{
		this.ui_workspace ();
		this.db.select_data ();
		this.load_sidebar ();
	}
	
	private void ui_welcome ()
	{
		this.toolbar.set_enable (false);
        this.pane.set_position (0);
        this.layout.init_welcome ();
		this.layout.welcome.activated.connect ((i) =>
		{
			switch (i)
			{
				case 0: this.add_subscription (); break;
				case 1: this.import_subscription (); break;
				//case 0: this.import_subscription (); break;
			}
		});
	}
	
	private void ui_welcome_to_workspace ()
	{
		this.toolbar.set_enable (true);
        this.layout.reinit ();
		this.ui_workspace ();
	}

	private void load_sidebar ()
	{
		stderr.printf ("load_sidebar ()\n");
		this.side.root.clear ();
		this.side.init ();
		int unread = 0;
		foreach (Model.Folder f in this.db.data)
		{
			var folder = new Granite.Widgets.SourceList.ExpandableItem (f.name);
			this.side.root.add (folder);
			foreach (Model.Channel c in f.channels)
			{
				folder.add (create_channel (c));
				unread += c.unread;
			}
		}
		this.side.root.expand_all ();
		this.manager.unread (unread);
	}

	private Feedler.SidebarItem create_channel (Model.Channel c)
	{
		string path = "%s/feedler/fav/%i.png".printf (GLib.Environment.get_user_data_dir (), c.id);
		Feedler.SidebarItem channel = null;				
		if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS))
			channel = new Feedler.SidebarItem (c.title, new GLib.FileIcon (GLib.File.new_for_path (path)), c.unread, true);
		else
			channel = new Feedler.SidebarItem (c.title, Feedler.Icons.RSS, c.unread, true);
		//channel.update.activate.connect ();
		channel.mark.activate.connect (channel_mark);
		channel.rename.activate.connect (channel_rename);
		channel.remove.activate.connect (channel_remove);
		channel.edited.connect (channel_rename_cb);
		channel.edit.activate.connect (channel_edit);
		return channel;
	}
	
	/* Events */
	private void change_mode (Gtk.Widget widget)
	{
		if (this.toolbar.mode.selected+1 == Feedler.Views.COLUMN)
			this.view = (Feedler.View)layout.get_nth_page (1);
		else
			this.view = (Feedler.View)layout.get_nth_page (this.toolbar.mode.selected+1);
		
		if (this.side.selected != null)
			this.channel_selected (this.side.selected);
	}

	private void config ()
	{
		Feedler.Preferences pref = new Feedler.Preferences ();
		//pref.update.fav.clicked.connect (_favicon_all);
		pref.run ();
        //pref.update.fav.clicked.disconnect (_favicon_all);
        pref.destroy ();
	}
	
	private void sidebar_update ()
	{
		if (this.toolbar.sidebar_visible.active)
			this.side.show ();
		else
			this.side.hide ();
	}
	
	private void fullscreen_mode ()
	{
		if (this.toolbar.fullscreen_mode.active)
			this.fullscreen ();
		else
			this.unfullscreen ();
	}

	private void channel_rename ()
	{
		this.side.start_editing_item (this.side.selected);
	}

	private void channel_rename_cb (string new_name)
	{
		var c = this.side.selected;
		if (new_name != c.name)
		{
			Model.Channel ch = this.db.get_channel (c.name);
			ch.title = new_name;
			this.infobar.question (new Feedler.RenameTask (this.db, c, ch, c.name));
		}
	}

	private void channel_remove ()
	{
		var c = this.side.selected;
		c.visible = false;
		this.infobar.question (new Feedler.RemoveTask (this.db, c));
	}

	private void channel_mark ()
	{
		var c = this.side.selected;
		int diff = (c.badge != null) ? int.parse (c.badge)*(-1) : 0;
		this.manager.unread (diff);
		c.badge = null;
		this.db.mark_channel (c.name);
	}
	
	private void channel_edit ()
	{
		var ch = this.side.selected;
		unowned Model.Channel c = this.db.get_channel (ch.name);
		Feedler.Subscription subs = new Feedler.Subscription ();
		subs.set_transient_for (this);
        //subs.saved.connect (create_subs_cb);
		foreach (Model.Folder folder in this.db.data)
		    subs.add_folder (folder.id, folder.name);
		subs.set_model (c.id, c.title, c.source, c.folder.id);
        subs.show_all ();		
	}

	internal void channel_mark_update (string title, int unread)
	{
		var ch = this.side.selected;
		if (ch.name == title)
			this.channel_selected (ch);
		foreach (var f in this.side.root.children)
		{
			var expandable = f as Granite.Widgets.SourceList.ExpandableItem;
            if (expandable != null)
				foreach (var c in expandable.children)
					if (c.name == title)
					{
						c.badge = unread.to_string ();
						return;
					}
		}
	}

	private void all_mark ()
    {
		this.manager.unread (this.manager.count*(-1));
		this.side.unread.badge = null;
		foreach (var f in this.side.root.children)
		{
			var expandable = f as Granite.Widgets.SourceList.ExpandableItem;
            if (expandable != null)
				foreach (var c in expandable.children)
					c.badge = null;
		}
		this.db.mark_all ();
		if (this.side.selected != null)
			this.channel_selected (this.side.selected);
    }

	private void item_mark (int id, Model.State state)
    {
		stderr.printf ("item_mark\n");
		var ch = this.side.selected;
		unowned Model.Channel c = this.db.get_channel (ch.name);
		unowned Model.Item it;
		bool reload = true;
		if (c != null)
		{
			it = c.get_item (id);
			reload = false;
		}
		else
		{
			it = this.db.get_item_from_tmp (id);
			c = it.channel;
		}
		if (state == Model.State.STARRED || state == Model.State.UNSTARRED)
		{
			bool star = (state == Model.State.STARRED) ? true : false;
			it.starred = star;
			this.channel_selected (this.side.selected);
			this.db.star_item (id, star);
			return;
		}

		int diff = 0;
		if (state == Model.State.READ)
			diff--;
		else if (state == Model.State.UNREAD)
			diff++;
		int counter = (ch.badge != null) ? int.parse (ch.badge) + diff : diff;
		if (counter > 0)
			ch.badge = counter.to_string ();
		else
			ch.badge = null;
		this.manager.unread (diff);
		c.unread += diff;
		bool read = (state == Model.State.READ) ? true : false;
		it.read = read;
		this.db.mark_item (id, read);
		if (reload)
			this.channel_selected (this.side.selected);
    }

	private void item_search ()
	{
		this.view.refilter (this.toolbar.search.get_text ());
	}

	private void item_next ()
	{
		foreach (var f in this.side.root.children)
		{
			var e = f as Granite.Widgets.SourceList.ExpandableItem;
			foreach (var c in e.children)
				if (c.badge != null && c.badge.strip () != "")
				{
					this.side.selected = c;
					return;
				}
		}
	}

	private void channel_selected (Granite.Widgets.SourceList.Item? channel)
	{
		unowned GLib.List<Model.Item?> items = null;
		if (channel == side.all)
			items = this.db.get_items (Model.State.ALL);
		else if (channel == side.unread)
			items = this.db.get_items (Model.State.UNREAD);
		else if (channel == side.star)
			items = this.db.get_items (Model.State.STARRED);
		else
			items = this.db.get_channel (channel.name).items;
		this.load_view (items);	
	}

	private void load_view (GLib.List<Model.Item?> items)
	{
		stderr.printf ("load_view\n");
		if (items.length () < 1)
		{
			this.layout.display (Feedler.Views.ALERT);
			return;			
		}
		this.layout.display ((Feedler.Views)this.toolbar.mode.selected+1);
	
		this.view.clear ();
		GLib.Time current_time = GLib.Time.local (time_t ());
		foreach (Model.Item item in items)
		{
			GLib.Time feed_time = GLib.Time.local (item.time);
		    if (feed_time.day_of_year + 6 < current_time.day_of_year)
		        this.view.add_feed (item, feed_time.format ("%d %B %Y"));
			else
		        this.view.add_feed (item, feed_time.format ("%A %R"));
		}
		this.view.load_feeds ();
	}

	private void add_folder ()
    {
        Feedler.Folder fol = new Feedler.Folder ();
		fol.set_transient_for (this);
        //fol.saved.connect (create_folder_cb);
        fol.show_all ();
	}

	private void add_subscription ()
    {
        Feedler.Subscription subs = new Feedler.Subscription ();
		subs.set_transient_for (this);
        subs.saved.connect (create_subs_cb);
		foreach (Model.Folder folder in this.db.data)
		    subs.add_folder (folder.id, folder.name);
        subs.show_all ();
		//this.stat.add_feed.button_press_event.disconnect (_create_subs);
	}
	
	private void create_subs_cb (int id, int folder, string title, string url)
    {
		//this.stat.add_feed.button_press_event.connect (_create_subs);
		//if (id == -1 || folder == -1)
		//	return;
		try
		{
			if (!this.db.is_created ())
			{
		    	this.db.create ();
		    	this.db.begin ();
		    	Serializer.Folder f = Serializer.Folder (); f.name = _("Subscriptions");
		    	this.db.insert_folder (f);
				this.db.commit ();
			    this.ui_welcome_to_workspace ();
				this.show_all ();
				folder = 1;
				var _folder = new Granite.Widgets.SourceList.ExpandableItem (f.name);
				this.side.root.add (_folder);
			    Model.Folder ff = new Model.Folder.with_data (folder, f.name);
				this.db.data.append (ff);
			    //http://rss.feedsportal.com/c/32739/f/530495/index.rss
			}

			Serializer.Channel sch = Serializer.Channel.no_data ();
			sch.title = title; sch.source = url;
		    unowned Model.Channel ch = this.db.insert_channel (folder, sch);
		    if (folder > 0)
		    {
				foreach (var child in this.side.root.children)
					if (child.name == ch.folder.name)
					{
						var expandable_item = child as Granite.Widgets.SourceList.ExpandableItem;
						expandable_item.add (create_channel (ch));
						break;
					}
			}
			//else
			//    this.side.root.add (create_channel (ch));
			this.client.add (url);
			//stderr.printf ("Bede nakurwiac!");
		}
        catch (GLib.Error e)
        {
            this.dialog ("Cannot connect to service!", Gtk.MessageType.ERROR);
        }
    }

	private void import_subscription ()
	{
		var file = new Gtk.FileChooserDialog ("Open File", this, Gtk.FileChooserAction.OPEN,
                                              Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                                              Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT);
		
		Gtk.FileFilter filter_opml = new Gtk.FileFilter ();
		filter_opml.set_filter_name ("Subscriptions");
		filter_opml.add_pattern ("*.opml");
		filter_opml.add_pattern ("*.xml");
		file.add_filter (filter_opml);

		Gtk.FileFilter filter_all = new Gtk.FileFilter ();
		filter_all.set_filter_name ("All files");
		filter_all.add_pattern ("*");
		file.add_filter (filter_all);

        if (file.run () == Gtk.ResponseType.ACCEPT)
        {
			string path = file.get_filename ();
			file.close ();
			this.manager.begin (_("Importing subscriptions"));
            try
            {
                if (!this.db.is_created ())
				{
                    this.db.create ();
	                this.ui_welcome_to_workspace ();
			        this.show_all ();
				}
				this.client.import (path);
            }
            catch (GLib.Error e)
            {
                this.dialog ("Cannot connect to service!", Gtk.MessageType.ERROR);
				this.manager.error ();
            }
        }
        file.destroy ();
	}

	internal void update_subscription ()
	{
        try
        {
            string[] uris = this.db.get_channels_uri ();
			this.manager.begin (_("Updating subscriptions"), uris.length);
            this.client.update_all (uris);
			//this.client.update ("http://iloveubuntu.net/rss.xml");
        }
        catch (GLib.Error e)
        {
            this.dialog ("Cannot connect to service!", Gtk.MessageType.ERROR);
			this.manager.error ();
        }
	}

	private void dialog (string msg, Gtk.MessageType msg_type = Gtk.MessageType.INFO)
    {
         var info = new Gtk.MessageDialog (this, Gtk.DialogFlags.DESTROY_WITH_PARENT,
                                           msg_type, Gtk.ButtonsType.OK, msg);
         info.run ();
         info.destroy ();
    }

	private void notification (string msg)
    {
        try
        {
            this.client.notification (msg);
        }
        catch (GLib.Error e)
        {
            this.dialog ("Cannot connect to service!", Gtk.MessageType.ERROR);
        }
    }

	private bool destroy_app ()
	{
		if (Feedler.SETTING.hide_close)
		{
			this.hide ();
			return true;
		}
		else
		{
			int width, height;
			get_size (out width, out height);
			Feedler.STATE.window_width = width;
			Feedler.STATE.window_height = height;
			Feedler.STATE.sidebar_width = this.pane.position;
			Feedler.STATE.view_mode = (uint8)this.toolbar.mode.selected;
			return false;
		}
	}
}
