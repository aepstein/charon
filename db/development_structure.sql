CREATE TABLE "addresses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "addressable_id" integer, "addressable_type" varchar(255), "label" varchar(255), "street" varchar(255), "city" varchar(255), "state" varchar(255), "zip" varchar(255), "on_campus" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "administrative_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "copies" integer, "copies_expense" decimal, "repairs_restocking" decimal, "mailbox_wsh" integer, "total_request" decimal, "total" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "bases" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "structure_id" integer, "open_at" datetime, "closed_at" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "durable_good_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "description" varchar(255), "quantity" float, "price" float, "total" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "durable_goods_addendums" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "description" varchar(255), "quantity" decimal, "unit_price" decimal, "total" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "items" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "requestable_id" integer, "requestable_type" varchar(255), "request_amount" decimal, "requestor_comment" varchar(255), "allocation_amount" decimal, "allocator_comment" varchar(255), "request_id" integer, "node_id" integer, "parent_id" integer, "position" integer, "created_at" datetime, "updated_at" datetime, "allocatable_id" integer, "allocatable_type" varchar(255));
CREATE TABLE "local_event_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date_of_event" date, "title_of_event" varchar(255), "location_of_event" varchar(255), "purpose_of_event" varchar(255), "anticipated_no_of_attendees" integer, "admission_charge_per_attendee" decimal, "number_of_publicity_copies" integer, "rental_equipment_services" decimal, "total_copy_rate" decimal, "copyright_fees" decimal, "total_eligible_Expenses" decimal, "admission_charge_revenue" decimal, "total_request_amount" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "memberships" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "organization_id" integer, "user_id" integer, "registration_id" integer, "role_id" integer, "active" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "nodes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "requestable_type" varchar(255), "item_amount_limit" decimal, "item_quantity_limit" integer, "structure_id" integer, "parent_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "organizations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar(255), "last_name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "organizations_requests" ("organization_id" integer NOT NULL, "request_id" integer NOT NULL);
CREATE TABLE "publication_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "no_of_issues" integer, "no_of_copies_per_issue" integer, "total_copies" integer, "purchase_price" decimal, "revenue" decimal, "cost_publication" decimal, "total_cost_publication" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "registrations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "org_id" integer, "name" varchar(255), "purpose" varchar(255), "is_independent" boolean, "is_registered" boolean, "funding_sources" varchar(255), "number_of_undergrads" integer, "number_of_grads" integer, "number_of_staff" integer, "number_of_faculty" integer, "number_of_alumni" integer, "number_of_others" integer, "org_email" varchar(255), "when_updated" datetime, "adv_first_name" varchar(255), "adv_last_name" varchar(255), "adv_email" varchar(255), "adv_net_id" varchar(255), "adv_address" varchar(255), "pre_first_name" varchar(255), "pre_last_name" varchar(255), "pre_email" varchar(255), "pre_net_id" varchar(255), "tre_first_name" varchar(255), "tre_last_name" varchar(255), "tre_email" varchar(255), "tre_net_id" varchar(255), "vpre_first_name" varchar(255), "vpre_last_name" varchar(255), "vpre_email" varchar(255), "vpre_net_id" varchar(255), "officer_first_name" varchar(255), "officer_last_name" varchar(255), "officer_email" varchar(255), "officer_net_id" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "requests" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "basis_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "roles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "sessions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "session_id" varchar(255) NOT NULL, "data" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "speaker_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "speaker_name" varchar(255), "performance_date" date, "mileage" decimal, "number_of_speakers" integer, "nights_of_lodging" integer, "engagement_fee" decimal, "car_rental" decimal, "tax_exempt_expenses" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "stages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "position" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "structures" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "travel_event_expenses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "event_date" date, "event_title" varchar(255), "event_location" varchar(255), "event_purpose" varchar(255), "members_per_group" integer, "number_of_groups" integer, "mileage" decimal, "nights_of_lodging" integer, "per_person_fees" decimal, "per_group_fees" decimal, "total_eligible_expenses" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime, "updated_at" datetime, "net_id" varchar(255) NOT NULL, "crypted_password" varchar(255) NOT NULL, "password_salt" varchar(255) NOT NULL, "persistence_token" varchar(255) NOT NULL, "email" varchar(255) NOT NULL, "status" varchar(255) DEFAULT 'unknown' NOT NULL, "first_name" varchar(255), "middle_name" varchar(255), "last_name" varchar(255), "date_of_birth" date);
CREATE TABLE "versions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "item_id" integer, "requestable_type" varchar(255), "requestable_id" integer, "amount" decimal, "comment" text, "stage_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "index_organizations_requests_on_organization_id_and_request_id" ON "organizations_requests" ("organization_id", "request_id");
CREATE UNIQUE INDEX "index_registrations_on_org_id" ON "registrations" ("org_id");
CREATE INDEX "index_sessions_on_session_id" ON "sessions" ("session_id");
CREATE INDEX "index_sessions_on_updated_at" ON "sessions" ("updated_at");
CREATE UNIQUE INDEX "index_users_on_net_id" ON "users" ("net_id");
CREATE INDEX "index_users_on_persistence_token" ON "users" ("persistence_token");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090602145007');

INSERT INTO schema_migrations (version) VALUES ('20090602153554');

INSERT INTO schema_migrations (version) VALUES ('20090602193752');

INSERT INTO schema_migrations (version) VALUES ('20090604155626');

INSERT INTO schema_migrations (version) VALUES ('20090604171729');

INSERT INTO schema_migrations (version) VALUES ('20090604195715');

INSERT INTO schema_migrations (version) VALUES ('20090604200818');

INSERT INTO schema_migrations (version) VALUES ('20090605141819');

INSERT INTO schema_migrations (version) VALUES ('20090605142525');

INSERT INTO schema_migrations (version) VALUES ('20090605154144');

INSERT INTO schema_migrations (version) VALUES ('20090605162515');

INSERT INTO schema_migrations (version) VALUES ('20090607175908');

INSERT INTO schema_migrations (version) VALUES ('20090615163251');

INSERT INTO schema_migrations (version) VALUES ('20090616072031');

INSERT INTO schema_migrations (version) VALUES ('20090616134802');

INSERT INTO schema_migrations (version) VALUES ('20090616183314');

INSERT INTO schema_migrations (version) VALUES ('20090623185407');

INSERT INTO schema_migrations (version) VALUES ('20090623185543');

INSERT INTO schema_migrations (version) VALUES ('20090625161207');

INSERT INTO schema_migrations (version) VALUES ('20090625165755');

INSERT INTO schema_migrations (version) VALUES ('20090617135537');

INSERT INTO schema_migrations (version) VALUES ('20090623202356');

INSERT INTO schema_migrations (version) VALUES ('20090624184730');

INSERT INTO schema_migrations (version) VALUES ('20090629151825');