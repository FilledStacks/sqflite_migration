# Sqflite Migration Service

At the moment, using the user_version to track the database version in a sqflite database is very inconsistent between debug deploys and even over installing a new release build.

This package is a package used by the [FilledStacks](https://www.filledstacks.com) Development team in production for apps that require SQFLite to manage migrations in a more automatic-manual way. I know that sounds weird but you'll see what I mean.

## Setup

To start off you have to add the package into your pubspec.yaml file.

```yaml
dependencies:
  ...
  sqflite_migration_service:
```

This package works specifically with [sqflite](https://pub.dev/packages/sqflite) and I recommend you use that one too. If you're using a different sqlite DB please file an issue with the library and I can most likely abstract the DB usage away and allow you to supply your own sqlite library. This library provides you with a single service to use. `DatabaseMigrationService`. You can register this with injectable by adding it to your third party services module or registering it normally with your service provider like below. Or if you're using Provider for Dependency Injection you simply construct it and pass it to the Provider.

```dart
locator.registerLazySingleton(() => DatabaseMigrationService());
```

## How it works

So the reason for making this package was to improve the management and as always, the readability of the migration code and provide a cleaner way to manage those migrations. This implementation actually comes directly from one of our clients who implemented this migration setup for their backend. There are 3 main parts to using this library.

1. Creating your sql files as sql file using specific naming
2. Supplying a list of those sql files to the `DatabaseMigrationService`
3. Running the migration on every start

Lets start at the top.

### Create Sql schema and files

To keep things readable, the best approach we have is to keep the files separate, with the proper extensions to allow for code highlighting. In the root of your project folder create a new folder called `assets`. Inside that folder create a new folder called `sql`. Inside that folder create a new file called `1_create_schema.sql`. That is the naming convention. [schema_version_number]\_[migration_name].sql

- **scheme_version_number**: Any number, this will be the number that's compared to the current databaseVersion. If this number is larger than the currentDatabase version it will run the SQL queries that you have written in the sql file for that number and will update the database when it's complete.
- **migration_name**: I use underscore separated naming for consistency with the version number, but you can name it whatever you'd like. This is just a name to tell you what the migration is for. Keep it short, but make the name mean something. I know we all suck at naming, but suck it up, make it literal. something like `2_adds_description_into_todo.sql` or if it's feature related `3_alter_schema_for_favorites.sql`. Whatever you name it doesn't matter and it can change anytime, the only thing that can't change is the number in front of it. You don't want the same migrations running again.

Each query in the file has to be separated by a semi-colon. Here is an example of a schema file that we have in one of our projects.

```sql
CREATE TABLE user_address(
  id INTEGER PRIMARY KEY,
  customerId INT,
  latitude FLOAT,
  longitude FLOAT,
  customerNotes TEXT,
  label TEXT,
  placeId TEXT,
  streetShort TEXT,
  streetAdditional TEXT,
  streetNumber TEXT,
  city TEXT,
  state TEXT,
  zip TEXT,
  current INT
);

CREATE TABLE cart_products(
  id INTEGER PRIMARY KEY,
  additional_instructions TEXT,
  description TEXT,
  name TEXT,
  item_token TEXT,
  menu_id INTEGER,
  price INTEGER,
  quantity INTEGER,
  vendor_id INTEGER,
  options TEXT
);

CREATE TABLE cart_information(
  cash_fee INTEGER,
  credit_fee INTEGER,
  service_fee INTEGER,
  tax INTEGER,
  product_ids TEXT,
  subtotal INTEGER
);
```

Once you've created that file, open up your pubspec.yaml file and update the assets section add the entire `assets/sql/` folder.

```yaml
assets:
  - assets/sql/
```

### Run those migrations

In the initialise function of your `DatabaseService` you can now call `runMigration` pass it the `database` from sqflite and pass it all of your migration files.

```dart
  await _migrationService.runMigration(
    _database,
    migrationFiles: [
      '1_create_schema.sql',
      '2_add_description.sql',
    ],
  );
```

This will run the migration 1, if the database version is 1, then run 2. If you're already on 1 it'll only run 2. If you don't know what the `DatabaseService` is. You can watch the video about SQLite on [FilledStacks Youtube channel](https://www.youtube.com/filledstacks). That's it.

### Add a new migration

This is the part where the manual comment comes in when adding a new migration here are the steps.

1. Create a file in the sql folder, make sure the version number is higher than the last file in the folder. 
2. Add the name file name EXACTLY as it is into the list of `migrationFiles` for the `runMigration` function.

And that's basically it. Migration files in sql format, separated by semi-colons and automatically applied based on the version of your current database which persists properly over deployments. If you have any issues, don't hesitate to file it. 

### Custom database version key in shared preferences

The database version number is stored in shared preferences with the key `database_version_key` by default. That key can be changed by passing the parameter `databaseVersionKey` when calling `runMigration` of `DatabaseService`.

```dart
  await _migrationService.runMigration(
    _database,
    migrationFiles: [
      '1_create_schema.sql',
      '2_add_description.sql',
    ],
    databaseVersionKey: 'custom_db_version_key'
  );
```