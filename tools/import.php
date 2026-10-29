<?php
declare(strict_types=1);

/*
 * Imports a .sql file into a MySQL database using PHP's own driver.
 *
 * Use this when the bundled MariaDB command-line client fails with
 * "Plugin caching_sha2_password could not be loaded" - PHP 8 supports that
 * authentication method, the old client does not.
 *
 * Usage (Command Prompt, from the project folder):
 *
 *   C:\xampp\php\php.exe tools\import.php HOST PORT USER DATABASE [FILE]
 *
 * Example:
 *   C:\xampp\php\php.exe tools\import.php goldenglow-tip-861c.k.aivencloud.com 12127 avnadmin defaultdb
 *
 * It asks for the password. The password can also be supplied in the
 * SALEVISION_DB_PASSWORD environment variable, which skips the prompt and is
 * useful in scripts. Set SALEVISION_DB_SSL_CA to a ca.pem path if the host
 * requires a verified TLS connection.
 *
 * The default file is salevision_setup.sql in the project folder.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("This script must be run from the command line.\n");
}

$args = array_slice($argv, 1);
if (count($args) < 4) {
    fwrite(STDERR, "Usage: php tools/import.php HOST PORT USER DATABASE [FILE]\n");
    exit(1);
}

[$host, $port, $user, $database] = $args;
$sqlFile = $args[4] ?? dirname(__DIR__) . '/salevision_setup.sql';

if (!is_file($sqlFile)) {
    fwrite(STDERR, "SQL file not found: {$sqlFile}\n");
    exit(1);
}

$passwordFromEnv = getenv('SALEVISION_DB_PASSWORD');
$password = $passwordFromEnv;
if ($passwordFromEnv === false) {
    $password = promptPassword('Password (input is visible): ');
    if ($password === '') {
        fwrite(STDERR, "No password entered. Run the command again and type the database password at the prompt.\n");
        exit(1);
    }
}
$sslCa = getenv('SALEVISION_DB_SSL_CA') ?: '';

$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::MYSQL_ATTR_USE_BUFFERED_QUERY => true,
];
if ($sslCa !== '') {
    $options[PDO::MYSQL_ATTR_SSL_CA] = $sslCa;
    $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = getenv('SALEVISION_DB_SSL_VERIFY') !== 'false';
}

$dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $host, $port, $database);

try {
    $pdo = new PDO($dsn, $user, $password, $options);
} catch (PDOException $exception) {
    fwrite(STDERR, "Could not connect: " . $exception->getMessage() . "\n");
    fwrite(STDERR, "Check the host, port, user, password and database name. If the server requires a CA, download ca.pem from the provider and set SALEVISION_DB_SSL_CA to its full path.\n");
    exit(1);
}

$sql = file_get_contents($sqlFile);
if ($sql === false) {
    fwrite(STDERR, "Could not read {$sqlFile}\n");
    exit(1);
}

$statements = splitSqlStatements($sql);
$executed = 0;
foreach ($statements as $statement) {
    try {
        $handle = $pdo->query($statement);
        if ($handle !== false) {
            // Drain result sets so the next statement starts clean.
            $handle->fetchAll();
            $handle->closeCursor();
        }
        $executed++;
    } catch (PDOException $exception) {
        fwrite(STDERR, "\nFailed after {$executed} statements.\n");
        fwrite(STDERR, "Statement: " . substr(preg_replace('/\s+/', ' ', $statement) ?? '', 0, 160) . "\n");
        fwrite(STDERR, "Error: " . $exception->getMessage() . "\n");
        exit(1);
    }
}

echo "Executed {$executed} SQL statements.\n";

foreach (['products', 'orders', 'order_items', 'users'] as $table) {
    try {
        $count = $pdo->query("SELECT COUNT(*) FROM `{$table}`")->fetchColumn();
        printf("  %-12s %s rows\n", $table, $count);
    } catch (PDOException $exception) {
        printf("  %-12s MISSING (%s)\n", $table, $exception->getMessage());
        exit(1);
    }
}

echo "Done. The database is ready.\n";

/** Splits a SQL script on semicolons, ignoring those inside quotes and comments. */
function splitSqlStatements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $length = strlen($sql);
    $inSingle = $inDouble = $inBacktick = $inLineComment = $inBlockComment = false;

    for ($i = 0; $i < $length; $i++) {
        $char = $sql[$i];
        $next = $i + 1 < $length ? $sql[$i + 1] : '';

        if ($inLineComment) {
            if ($char === "\n") {
                $inLineComment = false;
                $buffer .= "\n";
            }
            continue;
        }

        if ($inBlockComment) {
            if ($char === '*' && $next === '/') {
                $inBlockComment = false;
                $i++;
            }
            continue;
        }

        if (!$inSingle && !$inDouble && !$inBacktick) {
            if ($char === '-' && $next === '-') {
                $inLineComment = true;
                $i++;
                continue;
            }
            if ($char === '/' && $next === '*') {
                $inBlockComment = true;
                $i++;
                continue;
            }
            if ($char === ';') {
                $statement = trim($buffer);
                if ($statement !== '') {
                    $statements[] = $statement;
                }
                $buffer = '';
                continue;
            }
        }

        if ($char === "'" && !$inDouble && !$inBacktick) {
            $inSingle = !$inSingle;
        } elseif ($char === '"' && !$inSingle && !$inBacktick) {
            $inDouble = !$inDouble;
        } elseif ($char === '`' && !$inSingle && !$inDouble) {
            $inBacktick = !$inBacktick;
        }

        if ($char === '\\' && ($inSingle || $inDouble) && $next !== '') {
            $buffer .= $char . $next;
            $i++;
            continue;
        }

        $buffer .= $char;
    }

    $statement = trim($buffer);
    if ($statement !== '') {
        $statements[] = $statement;
    }

    return $statements;
}

/** Reads one line from the terminal, using whatever the user types. */
function promptPassword(string $label): string
{
    fwrite(STDOUT, $label);
    $line = fgets(STDIN);
    fwrite(STDOUT, "\n");
    if ($line === false) {
        return '';
    }

    return rtrim($line, "\r\n");
}
