NINE_ONE_DB = Sequel.connect(Config.nine_one_database_url, max_connections: Config.db_pool)
