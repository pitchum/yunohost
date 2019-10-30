VirtualHost "{{ domain }}"
  enable = true
  ssl = {
    key = "/etc/yunohost/certs/{{ domain }}/key.pem";
    certificate = "/etc/yunohost/certs/{{ domain }}/crt.pem";
  }
  authentication = "ldap2"
  ldap = {
    hostname = "localhost",
    user = {
      basedn = "ou=users,dc=yunohost,dc=org",
      filter = "(&(objectClass=posixAccount)(mail=*@{{ domain }})(permission=cn=xmpp.main,ou=permission,dc=yunohost,dc=org))",
      usernamefield = "mail",
      namefield = "cn",
    },
  }


-- Discovery items
disco_items = {
  { "muc.{{ domain }}" },
  { "pubsub.{{ domain }}" },
  { "upload.{{ domain }}" },
  { "vjud.{{ domain }}" }
};

-- BOSH configuration (mod_bosh)
consider_bosh_secure = true
cross_domain_bosh = true

-- WebSocket configuration (mod_websocket)
consider_websocket_secure = true
cross_domain_websocket = true

-- Disable account creation by default, for security
allow_registration = false

-- Use LDAP storage backend for all stores
storage = "ldap"

-- Logging configuration
log = {
  info = "/var/log/metronome/metronome.log"; -- Change 'info' to 'debug' for verbose logging
  error = "/var/log/metronome/metronome.err";
  -- "*syslog"; -- Uncomment this for logging to syslog
  -- "*console"; -- Log to the console, useful for debugging with daemonize=false
}

------ Components ------
-- You can specify components to add hosts that provide special services,
-- like multi-user conferences, and transports.

---Set up a local BOSH service
Component "localhost" "http"
  modules_enabled = { "bosh" }

---Set up a MUC (multi-user chat) room server
Component "muc.{{ domain }}" "muc"
  name = "{{ domain }} Chatrooms"

  modules_enabled = {
    "muc_limits";
    "muc_log";
    "muc_log_mam";
    "muc_log_http";
    "muc_vcard";
  }

  muc_event_rate = 0.5
  muc_burst_factor = 10

---Set up a PubSub server
Component "pubsub.{{ domain }}" "pubsub"
  name = "{{ domain }} Publish/Subscribe"

  unrestricted_node_creation = true -- Anyone can create a PubSub node (from any server)

---Set up a HTTP Upload service
Component "jabber.{{ domain }}" "http_upload"
  name = "{{ domain }} Sharing Service"

  http_file_size_limit = 6*1024*1024
  http_file_quota = 60*1024*1024
  http_upload_file_size_limit = 100 * 1024 * 1024 -- bytes
  http_upload_quota = 10 * 1024 * 1024 * 1024 -- bytes
  http_upload_path = "/var/lib/metronome/jabber.{{ domain }}"
  http_external_url = "https://jabber.{{ domain }}/"

---Set up a VJUD service
Component "vjud.{{ domain }}" "vjud"
  ud_disco_name = "{{ domain }} User Directory"
