/**
 * database.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */
 
public class Feedler.Database : GLib.Object
{
	private SQLHeavy.Database db;
	private SQLHeavy.Transaction transaction;
	private SQLHeavy.Query query;
	private string location;
	internal GLib.List<Model.Folder> data;
	internal GLib.List<unowned Model.Item> tmp;
	
	construct
	{
		this.location = GLib.Environment.get_user_data_dir () + "/feedler/feedler.db";
		this.data = new GLib.List<Model.Folder> ();
        this.open ();
	}

    public void open ()
    {
        try
		{
			this.db = new SQLHeavy.Database (location, SQLHeavy.FileMode.READ | SQLHeavy.FileMode.WRITE);
		}
		catch (SQLHeavy.Error e)
		{
            this.db = null;
			stderr.printf ("Cannot find database.\n");
		}
    }

    public bool is_created ()
    {
        if (this.db != null)
            return true;
        return false;
    }

    public void create ()
	{
        try
        {
			GLib.DirUtils.create (GLib.Environment.get_user_data_dir () + "/feedler", 0755);
			GLib.DirUtils.create (GLib.Environment.get_user_data_dir () + "/feedler/fav", 0755);
			this.db = new SQLHeavy.Database (location, SQLHeavy.FileMode.READ | SQLHeavy.FileMode.WRITE | SQLHeavy.FileMode.CREATE);
			db.execute ("CREATE TABLE folders (id INTEGER PRIMARY KEY, name TEXT UNIQUE);");
			db.execute ("CREATE TABLE channels (id INTEGER PRIMARY KEY, title TEXT UNIQUE, source TEXT, link TEXT, folder INT);");
			db.execute ("CREATE TABLE items (id INTEGER PRIMARY KEY, title TEXT, source TEXT, author TEXT, description TEXT, time INT, read INT, starred INT, channel INT);");
		}
		catch (SQLHeavy.Error e)
		{
            this.db = null;
			stderr.printf ("Cannot create new database in %s.\n", location);
		}
	}

    public bool begin ()
    {
        try
		{
			this.transaction = db.begin_transaction ();
            return true;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot begin transaction.\n");
			return false;
		}
    }

    public bool commit ()
    {
        try
		{
			this.transaction.commit ();
            return true;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot commit transaction.\n");
			return false;
		}
    }

    public string[]? get_folder_uris (int id)
	{
        string[] uri = new string[0];
        /*foreach (var c in this.channels)
            if (c.folder == id)
                uri += c.source;*/
        return uri;
	}

    public unowned Model.Item? get_item (int channel, int id)
	{
		/*foreach (unowned Model.Channel ch in this.channels)
			if (ch.id == channel)
				foreach (unowned Model.Item it in ch.items)
		            if (id == it.id)
        		        return it;*/
		return null;
	}

    /*public int add_folder (string title)
	{
		try
        {
   			this.transaction = db.begin_transaction ();
			query = transaction.prepare ("INSERT INTO `folders` (`name`, `parent`) VALUES (:name, :parent);");
			query.set_string (":name", title);
			//query.set_int (":parent", folder.parent);
            int id = (int)query.execute_insert ();
    		this.transaction.commit ();
            Model.Folder f = new Model.Folder.with_data (id, title, 0);
            this.folders.append (f);
            return id;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert folder %s.", title);
            return 0;
		}
	}

    public void update_folder (int id, string title)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE `folders` SET `name`=:name WHERE `id`=:id;");
			query.set_string (":name", title);
            query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
            Model.Folder c = this.get_folder (id);
            c.name = title;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot update folder %s with id %i.", title, id);
		}
    }

    public void remove_folder (int id)
	{
        try
        {
			transaction = db.begin_transaction ();
            query = transaction.prepare ("DELETE FROM `folders` WHERE `id` = :id;");
			query.set_int (":id", id);
			query.execute_async ();
			query = transaction.prepare ("DELETE FROM `channels` WHERE `folder` = :id;");
			query.set_int (":id", id);
			query.execute_async ();
			query = transaction.prepare ("DELETE FROM `items` WHERE `channel` IN (SELECT id FROM channels WHERE folder=:id);");
			query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
			this.folders.remove (this.get_folder (id));
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot remove channel.\n");
		}
	}

    public int add_channel (string title, string url, int folder)
	{
		try
        {
    		this.transaction = db.begin_transaction ();
            query = transaction.prepare ("INSERT INTO `channels` (`title`, `source`, `folder`) VALUES (:title, :source, :folder);");
			query.set_string (":title", title);
			query.set_string (":source", url);
			query.set_int (":folder", folder);
            int id = (int)query.execute_insert ();
            this.transaction.commit ();
            Model.Channel c = new Model.Channel.with_data (id, title, "", url, folder);
            this.channels.append (c);
            return id;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert channel %s.", title);
            return 0;
		}
	}

	public void update_link (string source, string link)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE `channels` SET `link`=:link WHERE `source`=:source;");
			query.set_string (":source", source);
            query.set_string (":link", link);
			query.execute_async ();
			transaction.commit ();
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot update channel with source %s.", source);
		}
    }

    public void update_channel (int id, int folder, string title,  string url)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE `channels` SET `title`=:title, `source`=:url, `folder`=:folder WHERE `id`=:id;");
			query.set_string (":title", title);
            query.set_string (":url", url);
			query.set_int (":folder", folder);
            query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
            Model.Channel c = this.get_channel (id);
            c.folder = folder;
            c.title = title;
            c.source = url;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot update channel %s with id %i.", title, id);
		}
    }
	
	public void remove_channel (int id)
	{
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("DELETE FROM `channels` WHERE `id` = :id;");
			query.set_int (":id", id);
			query.execute_async ();
			query = transaction.prepare ("DELETE FROM `items` WHERE `channel` = :id;");
			query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
			this.channels.remove (this.get_channel (id));
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot remove channel.\n");
		}
	}

    public void mark_folder (int id, Model.State state = Model.State.READ)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE `items` SET `state`=:state WHERE `channel` IN (SELECT id FROM channels WHERE folder=:id);");
			query.set_int (":state", (int)state);
            query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
            foreach (var i in this.channels)
                if (i.folder == id)
                    foreach (var j in i.items)
                        j.state = state;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark folder %i.", id);
		}
    }

    public void mark_channel (int id, Model.State state = Model.State.READ)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE `items` SET `state`=:state WHERE `channel`=:id;");
			query.set_int (":state", (int)state);
            query.set_int (":id", id);
			query.execute_async ();
			transaction.commit ();
            this.set_channel_state (id, state);
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark channel %i.", id);
		}
    }*/

	public unowned GLib.List<Model.Folder?> select_data ()
	{
        try
        {
			var query = new SQLHeavy.Query (db, "SELECT * FROM folders;");
			for (var results = query.execute (); !results.finished; results.next ())
			{
				Model.Folder fo = new Model.Folder ();
				fo.id = results.fetch_int (0);
				fo.name = results.fetch_string (1);
				fo.channels = new GLib.List<Model.Channel?> ();
				
				var que = new SQLHeavy.Query (db, "SELECT * FROM channels WHERE folder=:id;");
				que.set_int (":id", fo.id);
				for (var res = que.execute (); !res.finished; res.next ())
				{
					Model.Channel ch = new Model.Channel ();
					ch.id = res.fetch_int (0);
					ch.title = res.fetch_string (1);
					ch.source = res.fetch_string (2);
					ch.link = res.fetch_string (3);
					ch.folder = fo;
		            ch.items = new GLib.List<Model.Item?> ();
				
					var q = new SQLHeavy.Query (db, "SELECT * FROM items WHERE channel=:id;");
		            q.set_int (":id", ch.id);
					for (var r = q.execute (); !r.finished; r.next ())
					{
						Model.Item it = new Model.Item ();
		                it.id = r.fetch_int (0);
						it.title = r.fetch_string (1);
						it.source = r.fetch_string (2);
						it.author = r.fetch_string (3);
						it.description = r.fetch_string (4);
						it.time = r.fetch_int (5);
						it.read = (bool)r.fetch_int (6);
						it.starred = (bool)r.fetch_int (7);
						it.channel = ch;
						if (!it.read)
							ch.unread++;
						ch.items.append (it);				
					}
					fo.channels.append (ch);
				}
				this.data.append (fo);
			}
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot select all data.\n");
		}
		return data;
	}

	public int select_max (string table = "folders")
	{
        try
        {
			var query = new SQLHeavy.Query (db, "SELECT MAX(id) FROM %s;".printf (table));
			for (var results = query.execute (); !results.finished; results.next ())
			{
				return results.fetch_int (0);
			}
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot select index.\n");
		}
		return -1;
	}

	public unowned Model.Folder? get_folder (string name)
	{
		foreach (unowned Model.Folder f in this.data)
           	if (name == f.name)
               	return f;
		return null;
	}
	
	public unowned Model.Folder? get_folder_from_id (int id)
	{
		foreach (unowned Model.Folder f in this.data)
           	if (id == f.id)
               	return f;
		return null;
	}

	public unowned Model.Channel? get_channel (string title)
	{
		foreach (unowned Model.Folder f in this.data)
			foreach (unowned Model.Channel c in f.channels)
            	if (title == c.title)
                	return c;
		return null;
	}

	public unowned Model.Channel? get_channel_from_source (string source)
	{
		foreach (unowned Model.Folder f in this.data)
			foreach (unowned Model.Channel c in f.channels)
            	if (source == c.source)
                	return c;
		return null;
	}

	public unowned GLib.List<Model.Item> get_items (Model.State state = Model.State.ALL)
	{
		this.tmp = new GLib.List<Model.Item?> ();
		GLib.CompareFunc<Model.Item?> timecmp = (a, b) =>
		{
			return (int)(a.time > b.time) - (int)(a.time < b.time);
		};
		if (state == Model.State.ALL)
		{
			foreach (Model.Folder f in this.data)
				foreach (Model.Channel c in f.channels)
					foreach (Model.Item i in c.items)
		           		tmp.insert_sorted (i, timecmp);
		}
		else if (state == Model.State.UNREAD)
		{
			foreach (Model.Folder f in this.data)
				foreach (Model.Channel c in f.channels)
					foreach (Model.Item i in c.items)
			        	if (!i.read)
		            		tmp.insert_sorted (i, timecmp);
		}
		else if (state == Model.State.STARRED)
		{
			foreach (Model.Folder f in this.data)
				foreach (Model.Channel c in f.channels)
					foreach (Model.Item i in c.items)
			        	if (i.starred)
		            		tmp.insert_sorted (i, timecmp);
		}
		return tmp;
	}

	public unowned Model.Item? get_item_from_tmp (int id)
	{
		foreach (unowned Model.Item i in this.tmp)
			if (i.id == id)
				return i;
		return null;
	}

	public string[]? get_channels_uri ()
	{
        uint i = 0;
		foreach (Model.Folder f in this.data)
			i += f.channels.length ();
		string[] uri = new string[i];
		foreach (Model.Folder f in this.data)
			foreach (Model.Channel c in f.channels)
				uri[--i] = c.source;
        return uri;
	}

	public void mark_all ()
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE items SET read=:state WHERE read=:s;");
			query.set_int (":state", 1);
            query.set_int (":s", 0);
			query.execute_async ();
			transaction.commit ();
			foreach (Model.Folder f in this.data)
				foreach (Model.Channel c in f.channels)
					foreach (Model.Item i in c.items)
						if (!i.read)
							i.read = true;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark all channels.");
		}
    }

	public void mark_channel (string title)
    {
        try
        {
			var c = this.get_channel (title);
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE items SET read=:read WHERE channel=:id AND read=:unread;");
			query.set_int (":read", 1);
            query.set_int (":id", c.id);
			query.set_int (":unread", 0);
			query.execute_async ();
			transaction.commit ();
			foreach (Model.Item i in c.items)
				if (!i.read)
					i.read = true;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark channel %s.", title);
		}
    }

	public void mark_item (int item, bool mark)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE items SET read=:state WHERE id=:id;");
			query.set_int (":state", (int)mark);
            query.set_int (":id", item);
			query.execute_async ();
			transaction.commit ();
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark item %i.", item);
		}
    }

	public void star_item (int item, bool star)
    {
        try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE items SET starred=:state WHERE id=:id;");
			query.set_int (":state", (int)star);
            query.set_int (":id", item);
			query.execute_async ();
			transaction.commit ();
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot mark item %i.", item);
		}
    }

	public void rename_channel (string old_name, string new_name)
	{
		try
        {
			transaction = db.begin_transaction ();
			query = transaction.prepare ("UPDATE channels SET title=:new WHERE title=:old;");
			query.set_string (":old", old_name);
			query.set_string (":new", new_name);
			query.execute_async ();
			transaction.commit ();
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot rename channel %s to %s.", old_name, new_name);
		}
	}

	public void remove_channel (string name)
	{
        try
        {
			var c = this.get_channel (name);
			transaction = db.begin_transaction ();
			query = transaction.prepare ("DELETE FROM channels WHERE title=:name;");
			query.set_string (":name", name);
			query.execute_async ();
			query = transaction.prepare ("DELETE FROM items WHERE channel = :id;");
			query.set_int (":id", c.id);
			query.execute_async ();
			transaction.commit ();
			c.folder.channels.remove (c);
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot remove channel %s.\n", name);
		}
	}

	public void insert_folder (Serializer.Folder folder)
	//public void insert_folder (string name)
	{
		try
        {
        	//transaction = db.begin_transaction ();
            query = transaction.prepare ("INSERT INTO folders (name) VALUES (:name);");
			query.set_string (":name", folder.name);
			query.execute_async ();
			//int id = (int)query.execute_insert ();
			//transaction.commit ();
			//Model.Folder f = new Model.Folder.with_data (id, name);
			//this.data.append (f);
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert folder %s.\n", folder.name);
		}
	}

	public unowned Model.Channel insert_channel (int folder, Serializer.Channel schannel)
	{//mialobyc bez tranzakcji, poniewaz jest obslugiwana z poziomu managera w celu dodawania pozycji wsadowo!
        try
        {
			transaction = db.begin_transaction ();
            query = transaction.prepare ("INSERT INTO channels (title, source, link, folder) VALUES (:title, :source, :link, :folder);");
			query.set_string (":title", schannel.title);
			query.set_string (":source", schannel.source);
			query.set_string (":link", schannel.link);
			query.set_int (":folder", folder);
			int id = (int)query.execute_insert ();
			transaction.commit ();
			unowned Model.Folder f = this.get_folder_from_id (folder);
			Model.Channel c = new Model.Channel.with_data (id, schannel.title, schannel.link, schannel.source, f);
			f.channels.append (c);
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert channel %s.\n", schannel.title);
		}
		return this.get_channel (schannel.title);
	}
    
    /*public int insert_serialized_folder (Serializer.Folder folder)
	{
		try
        {
            query = transaction.prepare ("INSERT INTO folders (name) VALUES (:name);");
			query.set_string (":name", folder.name);
		    int id = (int)(query.execute_insert ());
            return id;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert folder %s.\n", folder.name);
            return 0;
		}
	}

    public int insert_serialized_channel (int folder, Serializer.Channel channel)
	{
        try
        {
            query = transaction.prepare ("INSERT INTO channels (title, source, link, folder) VALUES (:title, :source, :link, :folder);");
			query.set_string (":title", channel.title);
			query.set_string (":source", channel.source);
			query.set_string (":link", channel.link);
			query.set_int (":folder", folder);
            int id = (int)(query.execute_insert ());
            return id;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert channel %s.\n", channel.title);
            return 0;
		}
	}*/

    public int insert_item (int channel, Serializer.Item item)
	{
        try
        {
		    query = transaction.prepare ("INSERT INTO items (title, source, description, author, time, read, starred, channel) VALUES (:title, :source, :description, :author, :time, :read, :starred, :channel);");
			query.set_string (":title", item.title);
			query.set_string (":source", item.source);
			query.set_string (":author", item.author);
			query.set_string (":description", item.description);
			query.set_int (":time", item.time);
			query.set_int (":read", 0);
			query.set_int (":starred", 0);
			query.set_int (":channel", channel);
			int id = (int)query.execute_insert ();
            return id;
		}
		catch (SQLHeavy.Error e)
		{
			stderr.printf ("Cannot insert item %s.\n", item.title);
            return 0;
		}
	}

	public string export_to_opml ()
	{
		//Gee.Map<int, Xml.Node*> folder_node = new Gee.HashMap<int, Xml.Node*> ();
        Xml.Doc* doc = new Xml.Doc("1.0");
        /*Xml.Node* opml = doc->new_node (null, "opml", null);
        opml->new_prop ("version", "1.0");
        doc->set_root_element (opml);
        
        Xml.Node* head = new Xml.Node (null, "head");
        Xml.Node* h_title = doc->new_node (null, "title", "Feedler News Reader");
        Xml.Node* h_date = doc->new_node (null, "dateCreated", created_time ());
        head->add_child (h_title);
        head->add_child (h_date);
        opml->add_child (head);
        
        Xml.Node* body = new Xml.Node (null, "body");
        foreach (Model.Folder folder in this.folders)
        {
			Xml.Node* outline = new Xml.Node (null, "outline");
			outline->new_prop ("title", folder.name);
			outline->new_prop ("type", "folder");
			
			folder_node.set (folder.id, outline);
			body->add_child (outline);
		}
        foreach (Model.Channel channel in this.channels)
        {
			Xml.Node* outline = new Xml.Node (null, "outline");
			outline->new_prop ("text", channel.title);
			outline->new_prop ("type", "rss");
			outline->new_prop ("xmlUrl", channel.source);
			outline->new_prop ("htmlUrl", channel.link);
			if (channel.folder > 0)
			{
				Xml.Node* folder = folder_node.get (channel.folder);
				folder->add_child (outline);
			}
			else
				body->add_child (outline);
		}
        opml->add_child (body);*/

        string xmlstr; int n;
        doc->dump_memory (out xmlstr, out n);
        return xmlstr;
	}

	private string created_time ()
	{
		string currentLocale = GLib.Intl.setlocale(GLib.LocaleCategory.TIME, null);
        GLib.Intl.setlocale(GLib.LocaleCategory.TIME, "C");
		string date = GLib.Time.gm (time_t ()).format ("%a, %d %b %Y %H:%M:%S %z");
		GLib.Intl.setlocale(GLib.LocaleCategory.TIME, currentLocale);
		return date;
	}
}
