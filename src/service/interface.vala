/**
 * interface.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

/**
 * Update callback return:
 * 0> - error,
 * 0  - no new feed,
 * 0< - number of new feeds.
 */
[DBus (name = "org.example.Feedler")]
interface Feedler.Client : Object
{
    public abstract void favicon (string uri) throws IOError;
    public abstract void favicon_all (string[] uris) throws IOError;
	public abstract void add (string uri) throws IOError;
    public abstract void import (string uri) throws IOError;
    public abstract void update (string uri) throws IOError;
    public abstract void update_all (string[] uris) throws IOError;
    public abstract void notification (string msg) throws IOError;
    public abstract string ping () throws IOError;
	public abstract Serializer.Folder[] get_data () throws GLib.IOError;

    public signal void iconed (string uri, uint8[] data);
	public signal void added (Serializer.Channel channel);
    public signal void imported (Serializer.Folder[] folders);
  	public signal void updated (Serializer.Channel channel);
}
