create index tests_domain on tests (domain(15));
create index queue_domain on queue (domain(15));
create index queue_priority on queue (priority);
create index tests_begin on tests (begin);
create index domain_delegation_history on delegation_history (domain(15));
create index domains_domain on domains (domain(15));
