select 
	inet_server_addr( ) AS "Server", 
	inet_server_port( ) AS "Port",
	current_database() AS "CurrentDatabase",
	version() AS "Version";