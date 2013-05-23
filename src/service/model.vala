/**
 * model.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public class Model.Folder
{
	public int id;
	public string name;
	public GLib.List<Model.Channel> channels;

	public Folder.with_data (int id, string name)
    {
        this.id = id;
        this.name = name;
    }

	public Model.Channel? channel (string title)
    {
        foreach (Model.Channel c in this.channels)
            if (title == c.title)
                return c;
        return null;
    }
}

public class Model.Channel
{
    public int id;
	public string title;
	public string link;
	public string source;
	public unowned Model.Folder folder;
	public int unread;
    public GLib.List<Model.Item> items;

    public Channel.with_data (int id, string title, string link, string source, Model.Folder? folder)
    {//if (folder == null) then channels go to root
        this.id = id;
        this.title = title;
        this.link = link;
        this.source = source;
        this.folder = folder;
    }

	public unowned Model.Item? item (string title)
    {
        foreach (unowned Model.Item i in this.items)
            if (title == i.title)
                return i;
        return null;
    }

    public unowned Model.Item? get_item (int id)
    {
        foreach (unowned Model.Item item in this.items)
            if (id == item.id)
                return item;
        return null;
    }

	public string last_item_title ()
	{
        if (this.items.length () > 0)
            return this.items.last ().data.title;
        return "";
	}
}

public class Model.Item
{
    public int id;
	public string title;
	public string source;
	public string author;
	public string description;
	public int time;
	public bool read;
	public bool starred;
	public unowned Model.Channel channel;

	public Item.with_data (int id, string title, string source, string author, string description, int time, Model.Channel channel)
    {
        this.id = id;
        this.title = title;
        this.source = source;
		this.author = author;
		this.description = description;
		this.time = time;
		this.read = false;
		this.starred = false;
        this.channel = channel;
    }
}

public enum Model.State
{
	ALL = -1, READ = 0, UNREAD = 1, STARRED = 2, UNSTARRED = 3;
}
