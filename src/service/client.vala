/**
 * client.vala
 * 
 * @author Daniel Kur <Daniel.M.Kur@gmail.com>
 * @see COPYING
 */

void main ()
{
    /* Needed only if your client is listening to signals; you can omit it otherwise */
    var loop = new MainLoop();

    /* Important: keep demo variable out of try/catch scope not lose signals! */
    Feedler.Client demo = null;

    try
    {
        demo = Bus.get_proxy_sync (BusType.SESSION, "org.example.Feedler",
                                                    "/org/example/feedler");

        demo.updated.connect ((channel) =>
        {
            stdout.printf ("%s with %i items:\n", channel.title, channel.items.length);
            foreach (var i in channel.items)
                stdout.printf ("\t%s by %s\n", i.title, i.author);
        });
        demo.imported.connect ((folders) =>
        {
            foreach (var f in folders)
            {
                stdout.printf ("%s\n", f.name);
                foreach (var c in f.channels)
                    stdout.printf ("\t%s from %s\n", c.title, c.source);
            }
        });
        demo.iconed.connect ((uri, data) =>
        {
            stdout.printf ("URI: %s\n", uri);
        });
        demo.update ("http://elementaryos.org/journal/rss.xml");      
        demo.favicon ("http://elementaryos.org/journal/rss.xml");
        //demo.import ("/home/d3ny/Pobrane/google-reader-subscriptions.xml");
        //demo.import ("/home/d3ny/Pobrane/livemarks.opml");
        //demo.update ("http://elementaryluna.blogspot.com/feeds/posts/default");
        //demo.update_all ();

        GLib.Timeout.add_seconds (10, () =>
        {
            demo.stop();
            stderr.printf ("Sending stop call.\n");
            loop.quit ();
            return false;
        });
    }
    catch (GLib.IOError e)
    {
        stderr.printf ("%s\n", e.message);
    }
    loop.run ();
}