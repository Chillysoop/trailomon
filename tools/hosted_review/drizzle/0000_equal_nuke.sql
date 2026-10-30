CREATE TABLE `review_responses` (
	`page` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`revision` integer DEFAULT 0 NOT NULL,
	`write_id` text NOT NULL,
	`payload` text NOT NULL,
	`saved_at` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `review_submissions` (
	`page` text NOT NULL,
	`revision` integer NOT NULL,
	`part` integer NOT NULL,
	`parts` integer NOT NULL,
	`payload_chunk` text NOT NULL,
	`finished_at` text NOT NULL,
	PRIMARY KEY(`page`, `part`)
);
