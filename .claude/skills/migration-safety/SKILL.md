---
name: migration-safety
description: Safely plan and execute database migrations. Consider rollback paths, data integrity, and failure modes. Treat migrations as dangerous operations.
---

# Migration Safety Skill

Safely plan and execute database migrations.

## Core Principle

> Treat migrations as dangerous operations. Always consider what happens if this fails halfway.

## When to Use

- Creating new migrations
- Reviewing migration code
- Planning schema changes
- Before deploying migrations

## Read the repo's guard rails first

Most Rails repos already enforce migration safety mechanically, and what they
enforce differs. Before writing anything, check for:

- **`strong_migrations`** in the Gemfile. If present, it blocks a bare
  `remove_column`, a `change_column_null ... false`, and more. Read
  `config/initializers/strong_migrations.rb` if it exists. **If it does not,
  that is itself a finding**: without a `lock_timeout` and a `statement_timeout`
  a long migration can hold a lock indefinitely, and the gem will warn about it
  in production.
- **Custom cops.** A repo may enforce migration rules the gem has no opinion on,
  through its own RuboCop cops. A migration that satisfies the gem can still fail
  that repo's CI. Look for a `lib/cops/` directory or migration-scoped rules in
  `.rubocop.yml`.

**One dangerous pattern the gem does not catch:** `add_index` with
`algorithm: :concurrently` and no `disable_ddl_transaction!`. The gem checks only
that you used `concurrently`, never that you left the transaction on, so this
passes every guard and then fails at Postgres with `CREATE INDEX CONCURRENTLY
cannot run inside a transaction block`. Always pair the two.

## Pre-Migration Checklist

### 1. Reversibility
- [ ] Can this migration be rolled back?
- [ ] Is the `down` method correct?
- [ ] What data is lost on rollback?

### 2. Data Integrity
- [ ] Does this change existing data?
- [ ] What happens to existing records?
- [ ] Are there NULL values that need handling?
- [ ] Are there foreign key constraints to consider?

### 3. Failure Modes
- [ ] What if this fails halfway through?
- [ ] Is the migration idempotent?
- [ ] What state is the database left in on failure?

### 4. Performance
- [ ] How long will this take on production data?
- [ ] Does this lock tables?
- [ ] Should this run during off-peak hours?

### 5. Deployment
- [ ] Is this backwards compatible with current code?
- [ ] Does code need to deploy before or after?
- [ ] Is there a maintenance window needed?

## Safe Patterns

### Adding Columns
```ruby
# Safe: nullable column, no default
add_column :users, :new_field, :string

# Safe: with default (Rails 5+)
add_column :users, :status, :string, default: 'active', null: false
```

### Removing Columns
```ruby
# Step 1: Stop using column in code (deploy)
# Step 2: Remove column (separate deploy)
remove_column :users, :deprecated_field
```

### Adding Indexes
```ruby
# Use concurrently for large tables (Postgres)
add_index :users, :email, algorithm: :concurrently

# Disable DDL transaction for concurrent operations
disable_ddl_transaction!
```

### Renaming Columns
```ruby
# DANGEROUS: Breaks code expecting old name
# Instead: Add new, migrate data, remove old

# Step 1: Add new column
add_column :users, :full_name, :string

# Step 2: Migrate data (in code or separate migration)
User.update_all('full_name = name')

# Step 3: Update code to use new column (deploy)

# Step 4: Remove old column (separate deploy)
remove_column :users, :name
```

## Dangerous Patterns (Avoid)

### Changing Column Types
```ruby
# DANGEROUS: Can fail with existing data
change_column :users, :age, :integer  # was string

# Instead: Add new column, migrate, remove old
```

### Adding NOT NULL Without Default
```ruby
# DANGEROUS: Fails if existing rows have NULL
add_column :users, :required_field, :string, null: false

# Instead: Add nullable, backfill, then add constraint
add_column :users, :required_field, :string
# Backfill in batches
change_column_null :users, :required_field, false
```

### Dropping Tables
```ruby
# DANGEROUS: Data loss, ensure nothing references it
# Step 1: Remove all code using the table
# Step 2: Wait for deploys to propagate
# Step 3: Drop table with explicit confirmation
drop_table :deprecated_table
```

## Large Table Strategies

For tables with millions of rows:

### Batch Updates
```ruby
# In a rake task, not migration
User.find_each(batch_size: 1000) do |user|
  user.update_column(:new_field, computed_value)
end
```

### Concurrent Index Creation
```ruby
disable_ddl_transaction!

def change
  add_index :large_table, :column, algorithm: :concurrently
end
```

### Online Schema Changes
Consider tools like:
- `pg_repack` (Postgres)
- `gh-ost` (MySQL)
- `lhm` gem

## Output Format

When planning a migration:

```markdown
## Migration Plan: [Description]

**Risk Level:** LOW | MEDIUM | HIGH
**Estimated Duration:** [time on production data]
**Rollback Complexity:** Simple | Moderate | Complex

### Changes
- [What changes]

### Rollback Path
- [How to undo]

### Data Impact
- [What happens to existing data]

### Deployment Order
1. [Step 1]
2. [Step 2]

### Failure Modes
- [What if X fails]: [consequence and recovery]
```

## Questions to Always Ask

1. What happens if this fails halfway?
2. Can I roll back without data loss?
3. How long will this take on production?
4. Is the code compatible before AND after?
5. Who is on call when this runs?
