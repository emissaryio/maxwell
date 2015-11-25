#!/usr/bin/env ruby

require 'mysql2'

tokens = %w(
ADD
AFTER
ALTER
BEGIN
BIT
CHANGE
COLLATE
COLUMN
CREATE
DATABASE
ENGINE
EXISTS
FIRST
IGNORE
IF
LIKE
MEDIUMINT
MODIFY
ONLINE
OFFLINE
SCHEMA
SMALLINT
TABLE
TINYINT
TEMPORARY

UNSIGNED
ZEROFILL
BIT
TINYINT
CHARACTER
SET
COLLATE
SMALLINT
MEDIUMINT
INT
INTEGER
BIGINT
REAL
DOUBLE
FLOAT
DECIMAL
NUMERIC
DATE
TIME
TIMESTAMP
DATETIME
YEAR
CHAR
VARCHAR
BINARY
VARBINARY
TINYBLOB
BLOB
MEDIUMBLOB
LONGBLOB
TINYTEXT
TEXT
MEDIUMTEXT
LONGTEXT
ENUM
SET

NOT
NULL
DEFAULT
CURRENT_TIMESTAMP

AUTO_INCREMENT
UNIQUE
PRIMARY
KEY
COMMENT
COLUMN_FORMAT
FIXED
DYNAMIC
DEFAULT
STORAGE
DISK
MEMORY

CONSTRAINT
WITH
PARSER
KEY_BLOCK_SIZE
USING
BTREE
HASH
INDEX
KEY
FULLTEXT
SPATIAL
FOREIGN

DROP

DISABLE
ENABLE
KEYS

RENAME
TO
AS

ORDER
BY

CONVERT
CHARSET

AVG_ROW_LENGTH
CHECKSUM
CONNECTION
DATA
DIRECTORY
INSERT_METHOD
NO
FIRST
LAST
DELAY_KEY_WRITE
MAX_ROWS
MIN_ROWS
PACK_KEYS
PASSWORD
DEFAULT
DYNAMIC
FIXED
COMPRESSED
REDUNDANT
COMPACT
TABLESPACE
STORAGE
DISK
MEMORY

ROW_FORMAT
UNION

RESTRICT
CASCADE

REFERENCES
MATCH
FULL
PARTIAL
SIMPLE
ON
DELETE
UPDATE
RESTRICT
CASCADE
SET
NULL
NO
ACTION

BOOL
BOOLEAN
TRUE
FALSE
)

tokens_allowed_in_names = []

tokens = tokens.select { |t| !t.empty? }.sort.uniq

$connection = Mysql2::Client.new(:database => 'test')

def discover_token_availability(tokens, array, sql)
  tokens.each do |token|
    begin
      $connection.query(sql % token)
      array.push(token)
    rescue Mysql2::Error => e
      if e.message !~ /You have an error in your SQL syntax/
        array.push(token)
      end
    end
  end
end

$connection.query("CREATE TABLE if not exists column_test ( id int(11) )")
discover_token_availability(tokens, tokens_allowed_in_names, "ALTER TABLE column_test add column %s int(11)");


File.open(File.dirname(__FILE__) + "/mysql_literal_tokens.g4", "w+") do |f|
  f.puts("grammar mysql_literal_tokens;")
  f.puts
  f.puts("tokens_available_for_names: (%s);" % tokens_allowed_in_names.join(" | "))
  f.puts

  f.puts <<-EOL

INT1: I N T '1';
INT2: I N T '2';
INT3: I N T '3';
INT4: I N T '4';
INT8: I N T '8';

  EOL

  tokens.select { |t| !t.empty? }.sort.uniq.each do |t|
    f.puts "%s: %s;" % [t, t.split(//).map { |c| c == "_" ? "'_'" : c }.join(' ')]
  end

  ('A'..'Z').map do |letter|
    f.puts("fragment %s: [%s%s];" % [letter, letter, letter.downcase]);
  end
end
