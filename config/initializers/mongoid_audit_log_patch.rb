# Monkey-patches mongoid-audit_log 0.6.1 to use Mongoid::StringifiedSymbol for
# the `action` field instead of the BSON Symbol type, which Mongoid 9 deprecates.
# The gem is required here (instead of by Bundler) so we can suppress the
# deprecation warning before Mongoid::AuditLog::Entry is defined.
# Existing Symbol values already persisted in the DB remain readable because
# StringifiedSymbol#demongoize accepts both String and Symbol input.

Mongoid::Warnings.instance_variable_set(:@symbol_type_deprecated, true)
require 'mongoid/audit_log'
Mongoid::AuditLog::Entry.field :action, type: Mongoid::StringifiedSymbol
