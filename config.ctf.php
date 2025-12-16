<?php

/*
 +-----------------------------------------------------------------------+
 | Roundcube Webmail IMAP Client - CTF Configuration                     |
 +-----------------------------------------------------------------------+
 | Configuration for CTF environment with fake mail servers              |
 +-----------------------------------------------------------------------+
*/

$config = [];

// ----------------------------------
// DATABASE SETTINGS
// ----------------------------------
$config['db_dsnw'] = 'mysql://roundcube:roundcube_password@db:3306/roundcubemail';

// ----------------------------------
// IMAP SETTINGS
// ----------------------------------
$config['default_host'] = 'imap';
$config['default_port'] = 143;
$config['imap_auth_type'] = 'LOGIN';
$config['imap_delimiter'] = '/';
$config['imap_conn_options'] = [
    'ssl' => [
        'verify_peer' => false,
        'verify_peer_name' => false,
    ],
];

// ----------------------------------
// SMTP SETTINGS
// ----------------------------------
$config['smtp_server'] = 'smtp';
$config['smtp_port'] = 25;
$config['smtp_user'] = '';
$config['smtp_pass'] = '';
$config['smtp_conn_options'] = [
    'ssl' => [
        'verify_peer' => false,
        'verify_peer_name' => false,
    ],
];

// ----------------------------------
// SYSTEM SETTINGS
// ----------------------------------
$config['support_url'] = '';
$config['product_name'] = 'CTF Webmail';
$config['des_key'] = 'rcmail-!24ByteDESkey*CTF*2024';
$config['cipher_method'] = 'AES-256-CBC';

// ----------------------------------
// PLUGINS
// ----------------------------------
$config['plugins'] = ['archive', 'zipdownload', 'enigma'];

// ----------------------------------
// USER INTERFACE
// ----------------------------------
$config['skin'] = 'elastic';
$config['language'] = 'en_US';
$config['date_format'] = 'Y-m-d';
$config['time_format'] = 'H:i';

// ----------------------------------
// USER PREFERENCES
// ----------------------------------
$config['create_default_folders'] = true;
$config['auto_create_user'] = true;

// ----------------------------------
// LOG SETTINGS
// ----------------------------------
$config['log_driver'] = 'file';
$config['log_dir'] = '/var/www/html/roundcube/logs/';
$config['log_date_format'] = 'Y-m-d H:i:s O';
$config['smtp_log'] = true;
$config['imap_log'] = true;

// ----------------------------------
// TEMP DIRECTORY
// ----------------------------------
$config['temp_dir'] = '/var/www/html/roundcube/temp/';

// ----------------------------------
// SESSION SETTINGS
// ----------------------------------
$config['session_lifetime'] = 30;
$config['session_domain'] = '';
$config['session_name'] = 'roundcube_sessid';
$config['session_auth_name'] = 'roundcube_sessauth';
$config['session_samesite'] = 'Lax';
$config['session_path'] = '/';

// ----------------------------------
// SECURITY
// ----------------------------------
$config['ip_check'] = false;
$config['referer_check'] = false;
$config['request_token'] = false;
$config['x_frame_options'] = 'sameorigin';
$config['enable_installer'] = false;
$config['force_https'] = false;

// ----------------------------------
// PERFORMANCE
// ----------------------------------
$config['enable_caching'] = true;
$config['messages_cache'] = 'db';
$config['imap_cache'] = 'db';

return $config;

