<?php

foreach( glob( '/var/www/html/wp-config/*.php' ) as $config ) {
	require( $config );
}

define( 'DB_NAME', $_ENV['WORDPRESS_DB_NAME'] );
define( 'DB_USER', $_ENV['MYSQL_USER'] ?? $_ENV['WORDPRESS_DB_USER'] );
define( 'DB_PASSWORD', $_ENV['MYSQL_PASSWORD'] ?? $_ENV['WORDPRESS_DB_PASSWORD'] );
define( 'DB_HOST', $_ENV['WORDPRESS_DB_HOST'] );

define( 'AUTH_KEY', $_ENV['WORDPRESS_AUTH_KEY'] );
define( 'SECURE_AUTH_KEY', $_ENV['WORDPRESS_SECURE_AUTH_KEY'] );
define( 'LOGGED_IN_KEY', $_ENV['WORDPRESS_LOGGED_IN_KEY'] );
define( 'NONCE_KEY', $_ENV['WORDPRESS_NONCE_KEY'] );
define( 'AUTH_SALT', $_ENV['WORDPRESS_AUTH_SALT'] );
define( 'SECURE_AUTH_SALT', $_ENV['WORDPRESS_SECURE_AUTH_SALT'] );
define( 'LOGGED_IN_SALT', $_ENV['WORDPRESS_LOGGED_IN_SALT'] );
define( 'NONCE_SALT', $_ENV['WORDPRESS_NONCE_SALT'] );

$table_prefix = 'wp_';

# content directory
define( 'WP_CONTENT_DIR', '/var/www/html/wp-content' );

/* That's all, stop editing! Happy blogging. */

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

require_once( ABSPATH . 'wp-settings.php' );
