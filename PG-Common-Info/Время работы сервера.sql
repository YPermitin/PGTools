SELECT 
	pg_postmaster_start_time() AS StartTime,
	date_trunc('second', current_timestamp - pg_postmaster_start_time()) as SecondsRunning,
	date_trunc('second', current_timestamp - pg_postmaster_start_time()) / 86400 as DaysRunning
