if ( CLIENT ) then return end // for security ^ㅡ^;

catherine.database.information = {
	db_module = "sqlite", -- Set 'Module' for connect to Database ( sqlite or mysqloo )
	db_hostname = "127.0.0.1", -- Set 'Hostname' for connect to Database ( 127.0.0.1 )
	db_account_id = "", -- Set 'Account ID' for connect to Database ( root )
	db_account_password = "", -- Set 'Account Password' for connect to Database ( 12345 )
	db_name = "", -- Set 'Database Name' for connect to Database ( catherine )
	db_port = 3306 -- Set 'Port' for connect to Database ( 3306 )
}