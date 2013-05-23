/**
 * abstract.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

public enum BACKENDS
{
    XML,
    READER;

    public GLib.Type to_type ()
    {
        switch (this)
        {
            case XML:
                return GLib.Type.from_name (typeof (BackendXml).name ());
            case READER:
                return GLib.Type.from_name (typeof (BackendXml).name ());//TODO: Reader
            default:
                assert_not_reached();
        }
    }
    
    public string to_string ()
    {
        switch (this)
        {
            case XML:
                return "XML";
            case READER:
                return "Google Reader";
            default:
                assert_not_reached();
        }
    }
}

public abstract class Backend : GLib.Object
{
    public abstract bool subscribe (string data, out Serializer.Folder[]? folders);
    public abstract bool refresh (string data, out Serializer.Channel? channel);
    public abstract void add (string uri);
    public abstract void import (string uri);
    public abstract void update (string uri);
    public abstract BACKENDS to_type ();
    public abstract string to_string ();

    internal unowned Feedler.Service service;
    internal static Soup.Session session;

    static construct
    {
        session = new Soup.SessionAsync ();
		//session.timeout = 5;
    }
}
