=Charon Finance System

This is a DEPRECATED platform to support operations of the shared campus governance
finance commissions: the undergraduate Student Assembly Finance Commission (SAFC)
and the Graduate and Professional Student Assembly Finance Commission (GPSAFC).
It supports tasks related to coordination of effort with Student Activities
Office (SAO), which manages student organization registration and policies
governing the operations of student organizations.  It also facilitates
initiation, submission, review, and allocation of funding requests submitted
by student organizations.

==Key Files

This application utilizes default Rails best practices as much as possible.
See the config directory for key settings:
* config/deploy.rb: Deployment to production using capistrano
* config/authorization_rules.rb: Role-based access control using
  declarative_authorization
* config/schedule.rb: Scheduled tasks via CRON using whenever gem.
* config/ldap.yml: LDAP configuration utilized by cornell_ldap gem to query
  Cornell University enterprise LDAP for information about users such as their
  affiliation status with the university.

==Specialized gem dependencies

* cornell\_assemblies\_rails: Provides common functionality that can be
  factored out of multiple assemblies rails applications, especially UI
  features and building blocks like bootstrap, widgets, SSO authentication
* cornell-assemblies-branding: Provides assemblies-specific branding for
  unique look and feel of Assemblies websites
* cornell_ldap: Used to query Cornell Directory
* cornell_netid: Used to parse Cornell-style netids

==Features and Philosophy

The intent of this application is to enable a completely paperless process for
student organizations to prepare and submit their funding applications and
for SAFC/GPSAFC commissioners and staff to review and allocate them.  The system
also seeks to coordinate effort with SAO by utilizing SAO registration data
wherever possible.

The key process elements supported by the system:
* An _organization_'s officers prepare a _fund request_, consisting of _fund items_.
* The _fund request_ must be in response to a _fund source_.  The allows any organization
  to be enabled to manage its own _fund requests_ but in practice, only SAFC and
  GPSAFC have this authority.
* The specific _fund items_ allowed and any associated constraints are determined
  by the _fund request type_.  Items may be associated with specialized calculation
  forms, categories, and limits per policy of the funding organization.  Type also
  may require approvals of specific types of officers and it may require that
  those officers digitally sign certain agreements.
* Once all the required approvals are registered, the _fund request_ is _submitted_
  and assigned to _fund queue_ with the earliest, unexpired deadline.  If no queue
  with an outstanding deadline exists, assignment to a queue requires administrative
  intervention.
* Outstanding requirements and deadlines are reported to officers of organizations
  when they see their application.
* The software supports an preliminary review stage where a tentative allocation is
  reported to organizations.  This allows SAFC to hold administrative review
  hearings for organizations that seek to correct errors in the initial decision
  or to provide additional supporting documentation neglected in the original submission.
* The final allocation is then reported out to the organization.  It can also be reported
  in a CSV form that is compatible with the university's Kuali Financial System accounting
  platform, enabling data to be loaded directly into the university's general ledger.
  
The system coordinates effort with SAO by downloading information about registered
student organizations from SAO's separate RDBMS system.
* Registration data are downloaded hourly.
* Only registrations that have changed since the last download are obtained by default.
* Registration data are mapped from the relatively flat, non-normal form in SAO
  to the relational form in the native system.
* Organizations' registration status and membership composition as recorded by SAO are
  crucial requirements to applying for funding, and this system assures compliance with
  university requirements by requesting organizations.

The system provides an audit log of all activities both for security purposes and to enable
business process analysis.
  
==Tests and Documentation

The application has two primary sources of tests and documentation:
* features/*.feature: Contains plain-English cucumber features covering the range of features
  provided by the software.  This feature set utilizes the now-disfavored pickle
  and email testing packages so it is harder to understand than those in our other
  Rails projects.
* spec/models: Unit tests of models

== Useful queries

For totals of requests under nodes
SELECT SUM(fund_editions.amount) FROM fund_editions INNER JOIN fund_items ON
fund_editions.fund_item_id = fund_items.id INNER JOIN fund_requests ON
fund_editions.fund_request_id = fund_requests.id WHERE ( fund_items.id IN
(SELECT fund_items.id FROM fund_items INNER JOIN fund_editions ON fund_items.id
= fund_editions.fund_item_id INNER JOIN local_event_expenses ON fund_editions.id
= local_event_expenses.fund_edition_id WHERE fund_editions.perspective =
'requestor' AND fund_items.node_id = 2 AND local_event_expenses.start_date
> '2012-01-01') OR CAST( fund_items.ancestry AS UNSIGNED INTEGER ) IN (SELECT
fund_items.id FROM fund_items INNER JOIN fund_editions ON fund_items.id =
fund_editions.fund_item_id INNER JOIN local_event_expenses ON fund_editions.id
= local_event_expenses.fund_edition_id WHERE fund_editions.perspective =
'requestor' AND fund_items.node_id = 2 AND local_event_expenses.start_date >
'2012-01-01') ) AND fund_requests.fund_queue_id = 8 AND
fund_editions.perspective='requestor';

