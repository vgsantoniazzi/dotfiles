---
name: rails-investigate-pg
description: Systematic investigation guide for PostgreSQL connection issues in Rails applications. Operator-focused debugging.
---

# PostgreSQL Connection Issues Investigation

Systematic approach to diagnosing why Rails cannot connect to PostgreSQL.

## Step 1: Identify the Error

Check Rails logs for the specific error type:
```bash
# Recent Rails logs
tail -100 log/development.log | grep -i postgres
tail -100 log/development.log | grep -i "connection\|refused\|authentication"
```

Common error types:
- `connection refused` - PostgreSQL not running or wrong port
- `authentication failed` - Wrong credentials
- `database does not exist` - Database not created
- `could not connect to server: No such file or directory` - Socket issue

## Step 2: Detect PostgreSQL Installation Type

```bash
# Check for Homebrew (macOS)
brew services list 2>/dev/null | grep postgres

# Check for Postgres.app
ls /Applications/Postgres.app 2>/dev/null

# Check for Docker
docker ps 2>/dev/null | grep postgres

# Check for system PostgreSQL (Linux)
systemctl status postgresql 2>/dev/null || service postgresql status 2>/dev/null
```

## Step 3: Installation-Specific Diagnosis

### Homebrew (macOS)

```bash
# Check service status
brew services list | grep postgres

# Find actual version installed
ls /opt/homebrew/var/ | grep postgres

# Check logs (replace VERSION)
tail -50 /opt/homebrew/var/log/postgresql@VERSION.log

# Common fix: stale PID file after crash
# If you see "postmaster.pid already exists":
rm /opt/homebrew/var/postgresql@VERSION/postmaster.pid
brew services restart postgresql@VERSION
```

### Postgres.app

1. Verify application is running (elephant icon in menu bar)
2. Check Server Settings in the app
3. Verify PATH: `which psql` should point to Postgres.app

### Docker

```bash
# Verify container is running
docker ps | grep postgres

# Check container logs
docker logs CONTAINER_NAME --tail 50

# Verify port mapping
docker port CONTAINER_NAME

# Common issue: container exited
docker ps -a | grep postgres
docker start CONTAINER_NAME
```

### System PostgreSQL (Linux)

```bash
# Check status
sudo systemctl status postgresql

# Check journal logs
sudo journalctl -u postgresql -n 50

# Common fix: start service
sudo systemctl start postgresql
```

## Step 4: Common Issues

### Port 5432 Already in Use

```bash
# Find what's using the port
lsof -i :5432

# If it's a zombie PostgreSQL
kill -9 PID
```

### Socket File Missing

```bash
# Find socket location
find /tmp -name ".s.PGSQL.*" 2>/dev/null
find /var/run/postgresql -name ".s.PGSQL.*" 2>/dev/null

# Check database.yml socket configuration matches actual location
```

### Database Configuration Mismatch

Compare `config/database.yml` with actual PostgreSQL config:
- Host (localhost vs 127.0.0.1 vs socket)
- Port (default 5432)
- Username (often your system username on dev)
- Database name

```bash
# Test connection directly
psql -h localhost -p 5432 -U USERNAME -d DATABASE_NAME
```

### Credentials Issues

```bash
# Check pg_hba.conf for auth method
# Location varies by installation
find / -name "pg_hba.conf" 2>/dev/null

# Common dev fix: change auth to trust (only for dev!)
# Then reload: pg_ctl reload -D /path/to/data
```

## Step 5: Verify Fix

```bash
# Quick Rails connection test
bin/rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').first"

# More verbose
bin/rails runner "
  puts 'Database: ' + ActiveRecord::Base.connection.current_database
  puts 'Host: ' + ActiveRecord::Base.connection_db_config.host.to_s
  puts 'Port: ' + ActiveRecord::Base.connection_db_config.configuration_hash[:port].to_s
"
```

## Step 6: Document Root Cause

After fixing, document:
- What was the actual problem?
- How was it diagnosed?
- How was it fixed?
- How to prevent recurrence?

Add to project CLAUDE.md if this is a recurring issue pattern.
