/* Indicate-0.7.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Indicate", gir_namespace = "Indicate", gir_version = "0.7", lower_case_cprefix = "indicate_")]
namespace Indicate {
	[CCode (cheader_filename = "libindicate/listener.h", type_id = "indicate_indicator_get_type ()")]
	public class Indicator : GLib.Object {
		[CCode (has_construct_function = false)]
		public Indicator ();
		public bool get_displayed ();
		public uint get_id ();
		[NoWrapper]
		public virtual GLib.Variant get_property (string key);
		public GLib.Variant get_property_variant (string key);
		public unowned Indicate.Server get_server ();
		public bool is_visible ();
		public GLib.GenericArray<string> list_properties ();
		public void set_displayed (bool displayed);
		[CCode (cname="indicate_indicator_set_property_variant")]
		public virtual void set_property (string key, GLib.Variant data);
		public void set_property_bool (string key, bool value);
		public void set_property_int (string key, int value);
		public void set_property_time (string key, GLib.TimeVal time);
		public void set_server (Indicate.Server server);
		[CCode (has_construct_function = false)]
		public Indicator.with_server (Indicate.Server server);
		public virtual signal void displayed (bool displayed);
		[HasEmitter]
		public virtual signal void hide ();
		public virtual signal void modified (string property);
		[HasEmitter]
		public virtual signal void show ();
		[HasEmitter]
		public virtual signal void user_display (uint timestamp);
	}
	[CCode (cheader_filename = "libindicate/listener.h", type_id = "indicate_listener_get_type ()")]
	public class Listener : GLib.Object {
		[CCode (has_construct_function = false)]
		public Listener ();
		public void display (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, uint timestamp);
		public void displayed (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, bool displayed);
		public void get_property (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, void* callback, void* data);
		public void get_property_bool (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, void* callback, void* data);
		public void get_property_int (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, void* callback, void* data);
		public void get_property_time (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, void* callback, void* data);
		public void get_property_variant (Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, void* callback, void* data);
		public static Indicate.Listener ref_default ();
		public bool server_check_interest (Indicate.ListenerServer server, Indicate.Interests interest);
		public void server_get_count (Indicate.ListenerServer server, void* callback, void* data);
		public void server_get_desktop (Indicate.ListenerServer server, void* callback, void* data);
		public void server_get_icon_theme (Indicate.ListenerServer server, void* callback, void* data);
		public GLib.List<weak Indicate.ListenerIndicator> server_get_indicators (Indicate.ListenerServer server);
		public void server_get_menu (Indicate.ListenerServer server, void* callback, void* data);
		public void server_get_type (Indicate.ListenerServer server, void* callback, void* data);
		public void server_remove_interest (Indicate.ListenerServer server, Indicate.Interests interest);
		public void server_show_interest (Indicate.ListenerServer server, Indicate.Interests interest);
		public void set_default_max_indicators (int max);
		public void set_server_max_indicators (Indicate.ListenerServer server, int max);
		public virtual signal void indicator_servers_report ();
	}
	[CCode (cheader_filename = "libindicate/listener.h", type_id = "indicate_server_get_type ()")]
	public class Server : GLib.Object {
		[CCode (has_construct_function = false)]
		protected Server ();
		public void add_indicator (Indicate.Indicator indicator);
		public virtual bool check_interest (Indicate.Interests interest);
		[NoWrapper]
		public virtual bool get_indicator_count (uint count) throws GLib.Error;
		[NoWrapper]
		public virtual bool get_indicator_property (uint id, string property, GLib.Variant value) throws GLib.Error;
		public int get_max_indicators ();
		public virtual uint get_next_id ();
		public unowned string get_path ();
		public void hide ();
		[NoWrapper]
		public virtual void indicator_added (uint id);
		[NoWrapper]
		public virtual bool indicator_displayed (string sender, uint id, bool displayed) throws GLib.Error;
		[NoWrapper]
		public virtual void indicator_removed (uint id);
		[NoWrapper]
		public virtual int max_indicators_get ();
		[NoWrapper]
		public virtual bool max_indicators_set (string sender, int max);
		public static Indicate.Server ref_default ();
		public void remove_indicator (Indicate.Indicator indicator);
		[NoWrapper]
		public virtual bool remove_interest (string sender, Indicate.Interests interest);
		public void set_count (uint count);
		public static void set_dbus_object (string obj);
		public void set_default ();
		public void set_desktop_file (string path);
		public void set_icon_theme (string name);
		public void set_menu (Dbusmenu.Server menu);
		public void set_type (string type);
		public void show ();
		[NoWrapper]
		public virtual bool show_indicator_to_user (uint id, uint timestamp) throws GLib.Error;
		[NoWrapper]
		public virtual bool show_interest (string sender, Indicate.Interests interest);
		[NoAccessorMethod]
		public uint count { get; set; }
		[NoAccessorMethod]
		public string desktop { owned get; set; }
		[NoAccessorMethod]
		public string icon_theme { owned get; set; }
		[NoAccessorMethod]
		public string menu { owned get; }
		public string path { get; construct; }
		[NoAccessorMethod]
		public string type { owned get; set; }
		public signal void indicator_delete (uint object);
		public virtual signal void indicator_modified (uint id, string property);
		public signal void indicator_new (uint object);
		public virtual signal void interest_added (uint interest);
		public virtual signal void interest_removed (uint interest);
		public virtual signal void max_indicators_changed (int max);
		public virtual signal void server_count_changed (uint count);
		public virtual signal void server_display (uint timestamp);
		public virtual signal void server_hide (string type);
		public virtual signal void server_show (string type);
	}
	[CCode (cheader_filename = "libindicate/listener.h", has_type_id = false)]
	public struct ListenerIndicator {
		public uint id;
		public static GLib.Type get_gtype ();
		public uint get_id ();
	}
	[CCode (cheader_filename = "libindicate/listener.h", has_type_id = false)]
	public struct ListenerServer {
		public weak string name;
		[CCode (array_length = false, array_null_terminated = true)]
		public weak bool[] interests;
		public int max_indicators;
		public unowned string get_dbusname ();
		public unowned string get_dbuspath ();
		public static GLib.Type get_gtype ();
	}
	[CCode (cheader_filename = "libindicate/listener.h", cprefix = "INDICATE_INTEREST_")]
	public enum Interests {
		NONE,
		SERVER_DISPLAY,
		SERVER_SIGNAL,
		INDICATOR_DISPLAY,
		INDICATOR_SIGNAL,
		INDICATOR_COUNT,
		LAST
	}
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_indicator_list_properties_slot_t", has_target = false)]
	public delegate GLib.GenericArray<string> indicator_list_properties_slot_t (Indicate.Indicator indicator);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_property_bool_cb", has_target = false)]
	public delegate void listener_get_property_bool_cb (Indicate.Listener listener, Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, bool propertydata, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_property_cb", has_target = false)]
	public delegate void listener_get_property_cb (Indicate.Listener listener, Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, string propertydata, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_property_int_cb", has_target = false)]
	public delegate void listener_get_property_int_cb (Indicate.Listener listener, Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, int propertydata, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_property_time_cb", has_target = false)]
	public delegate void listener_get_property_time_cb (Indicate.Listener listener, Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, GLib.TimeVal propertydata, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_property_variant_cb", has_target = false)]
	public delegate void listener_get_property_variant_cb (Indicate.Listener listener, Indicate.ListenerServer server, Indicate.ListenerIndicator indicator, string property, GLib.Variant propertydata, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_server_property_cb", has_target = false)]
	public delegate void listener_get_server_property_cb (Indicate.Listener listener, Indicate.ListenerServer server, string value, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_listener_get_server_uint_property_cb", has_target = false)]
	public delegate void listener_get_server_uint_property_cb (Indicate.Listener listener, Indicate.ListenerServer server, uint value, void* data);
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_server_get_indicator_list_slot_t", has_target = false)]
	public delegate bool server_get_indicator_list_slot_t (Indicate.Server server, out GLib.Array<weak Indicate.Indicator> indicators) throws GLib.Error;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_server_get_indicator_properties_slot_t", has_target = false)]
	public delegate bool server_get_indicator_properties_slot_t (Indicate.Server server, uint id, [CCode (array_length = false)] out string[] properties) throws GLib.Error;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "indicate_server_get_indicator_property_group_slot_t", has_target = false)]
	public delegate bool server_get_indicator_property_group_slot_t (Indicate.Server server, uint id, [CCode (array_length = false)] string[] properties, [CCode (array_length = false)] out string[] value) throws GLib.Error;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_H_INCLUDED__")]
	public const int INDICATOR_H_INCLUDED__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_H_INCLUDED__")]
	public const int INDICATOR_MESSAGES_H_INCLUDED__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_PROP_ATTENTION")]
	public const string INDICATOR_MESSAGES_PROP_ATTENTION;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_PROP_COUNT")]
	public const string INDICATOR_MESSAGES_PROP_COUNT;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_PROP_ICON")]
	public const string INDICATOR_MESSAGES_PROP_ICON;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_PROP_NAME")]
	public const string INDICATOR_MESSAGES_PROP_NAME;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_PROP_TIME")]
	public const string INDICATOR_MESSAGES_PROP_TIME;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_MESSAGES_SERVER_TYPE")]
	public const string INDICATOR_MESSAGES_SERVER_TYPE;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_SIGNAL_DISPLAY")]
	public const string INDICATOR_SIGNAL_DISPLAY;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_SIGNAL_DISPLAYED")]
	public const string INDICATOR_SIGNAL_DISPLAYED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_SIGNAL_HIDE")]
	public const string INDICATOR_SIGNAL_HIDE;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_SIGNAL_MODIFIED")]
	public const string INDICATOR_SIGNAL_MODIFIED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_SIGNAL_SHOW")]
	public const string INDICATOR_SIGNAL_SHOW;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_VALUE_FALSE")]
	public const string INDICATOR_VALUE_FALSE;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INDICATOR_VALUE_TRUE")]
	public const string INDICATOR_VALUE_TRUE;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_INTERESTS_H_INCLUDED__")]
	public const int INTERESTS_H_INCLUDED__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_H_INCLUDED__")]
	public const int LISTENER_H_INCLUDED__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_PRIVATE_H__")]
	public const int LISTENER_PRIVATE_H__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_INDICATOR_ADDED")]
	public const string LISTENER_SIGNAL_INDICATOR_ADDED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_INDICATOR_MODIFIED")]
	public const string LISTENER_SIGNAL_INDICATOR_MODIFIED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_INDICATOR_REMOVED")]
	public const string LISTENER_SIGNAL_INDICATOR_REMOVED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_SERVER_ADDED")]
	public const string LISTENER_SIGNAL_SERVER_ADDED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_SERVER_COUNT_CHANGED")]
	public const string LISTENER_SIGNAL_SERVER_COUNT_CHANGED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_LISTENER_SIGNAL_SERVER_REMOVED")]
	public const string LISTENER_SIGNAL_SERVER_REMOVED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_H_INCLUDED__")]
	public const int SERVER_H_INCLUDED__;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_INDICATOR_NULL")]
	public const int SERVER_INDICATOR_NULL;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_INDICATOR_ADDED")]
	public const string SERVER_SIGNAL_INDICATOR_ADDED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_INDICATOR_MODIFIED")]
	public const string SERVER_SIGNAL_INDICATOR_MODIFIED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_INDICATOR_REMOVED")]
	public const string SERVER_SIGNAL_INDICATOR_REMOVED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_INTEREST_ADDED")]
	public const string SERVER_SIGNAL_INTEREST_ADDED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_INTEREST_REMOVED")]
	public const string SERVER_SIGNAL_INTEREST_REMOVED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_MAX_INDICATORS_CHANGED")]
	public const string SERVER_SIGNAL_MAX_INDICATORS_CHANGED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_SERVER_COUNT_CHANGED")]
	public const string SERVER_SIGNAL_SERVER_COUNT_CHANGED;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_SERVER_DISPLAY")]
	public const string SERVER_SIGNAL_SERVER_DISPLAY;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_SERVER_HIDE")]
	public const string SERVER_SIGNAL_SERVER_HIDE;
	[CCode (cheader_filename = "libindicate/listener.h", cname = "INDICATE_SERVER_SIGNAL_SERVER_SHOW")]
	public const string SERVER_SIGNAL_SERVER_SHOW;
}
