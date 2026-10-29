<?php
declare(strict_types=1);

/*
 * Database connection settings come from the environment so the same code runs
 * on a laptop and on a host such as Render without editing this file.
 *
 *   SALEVISION_DB_HOST      hostname of the MySQL server
 *   SALEVISION_DB_PORT      port (default 3306)
 *   SALEVISION_DB_NAME      database name
 *   SALEVISION_DB_USER      database user
 *   SALEVISION_DB_PASSWORD  database password (may be empty for local XAMPP)
 *
 * For a managed MySQL service that requires TLS (for example Aiven), also set:
 *
 *   SALEVISION_DB_SSL_CA      absolute path to the provider's ca.pem file
 *   SALEVISION_DB_SSL_VERIFY  "false" to skip certificate verification
 *
 * The defaults below match a stock local XAMPP install and contain no secrets.
 */
return (static function (): PDO {
    $read = static function (string $key, string $default = ''): string {
        $value = getenv($key);
        return $value === false ? $default : $value;
    };

    $host = $read('SALEVISION_DB_HOST', '127.0.0.1');
    $port = $read('SALEVISION_DB_PORT', '3306');
    $database = $read('SALEVISION_DB_NAME', 'salevision');
    $username = $read('SALEVISION_DB_USER', 'root');
    $password = $read('SALEVISION_DB_PASSWORD');

    if ($host === '' || $database === '' || $username === '') {
        throw new RuntimeException(
            'Database connection is not configured. Set SALEVISION_DB_HOST, SALEVISION_DB_NAME '
            . 'and SALEVISION_DB_USER (plus port, password and SSL settings if required).'
        );
    }

    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $host,
        $port,
        $database
    );

    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];

    $sslCa = $read('SALEVISION_DB_SSL_CA');
    if ($sslCa !== '') {
        $options[PDO::MYSQL_ATTR_SSL_CA] = $sslCa;
        $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = $read('SALEVISION_DB_SSL_VERIFY', 'true') !== 'false';
    }

    return new PDO($dsn, $username, $password, $options);
})();
