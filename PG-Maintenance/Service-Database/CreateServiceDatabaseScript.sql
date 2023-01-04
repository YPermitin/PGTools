/*
Служебная база мониторинга по умолчанию имеет имя "PostgreSQLMaintenance"
*/

CREATE TABLE public."MaintenanceActionsLog" (
	id int8 NOT NULL GENERATED ALWAYS AS IDENTITY,
	"Period" timestamp NOT NULL,
	"DatabaseName" varchar NOT NULL,
	"TableName" varchar NOT NULL,
	"IndexName" varchar NOT NULL,
	"Operation" varchar NOT NULL,
	"SQLCommand" varchar NOT NULL
);