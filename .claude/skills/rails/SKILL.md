---
name: rails
description: Guide for Ruby on Rails development. Covers RSpec testing, Sidekiq job patterns, and Rails-specific conventions.
---

# Rails Development Guide

Comprehensive guidance for Rails applications: testing, background jobs, and conventions.

---

## Sidekiq Job Patterns

### Memory-Safe Iteration

**What you pass depends on the mechanism, not on preference.**
`Sidekiq::Worker` with `perform_async` serialises arguments to JSON, so pass
ids and reload inside the job. ActiveJob with `perform_later` serialises through
GlobalID, so pass the record and let it reload, which raises cleanly if the row
is gone. Check which one the repo uses before writing either.


```ruby
# Bad: loads all IDs into memory
Customer.pluck(:id).each do |id|
  ProcessCustomerJob.perform_later(id)
end

# Good: batches automatically
Customer.find_each do |customer|
  ProcessCustomerJob.perform_later(customer)
end
```

### Status Updates Before Enqueue

Prevent race conditions by updating status before enqueuing:

```ruby
# Bad: job may run before status is set
job_class.perform_later(record.id)
record.enqueued!

# Good: status set before job can run
record.enqueued!
job_class.perform_later(record.id)
```

### Error Handling Without Re-Raise

Never re-raise after marking failed - Sidekiq will retry zombie jobs:

```ruby
def perform(record)
  return if record.sent? || record.failed?

  do_work(record)
  record.sent!
rescue ActiveRecord::RecordNotFound
  # Record deleted, nothing to do
rescue => e
  record&.failed!
  Sentry.capture_exception(e)
  # NO re-raise - prevents zombie retries
end
```

---

## RSpec Testing

### Core Strategy

- **No controller tests** if you have spec/request and/or Capybara feature specs
- **Add unit tests** for every new method in models, services, and library classes
- Tests should mirror application structure

## Directory Structure

Read the repo's actual `spec/` tree before creating a file. Layouts differ:
some projects keep a single `spec/factories.rb`, others a `spec/factories/`
directory. Mirror what is already there; never introduce the other shape.

## Key Patterns

### Naming Conventions

```ruby
# Instance methods use #
describe '#calculate_total' do
  # ...
end

# Class methods use .
describe '.find_by_email' do
  # ...
end
```

### Context Usage

Every state in context should have a corresponding let variable:

```ruby
describe '#process' do
  context 'when order is valid' do
    let(:order) { build(:order, :valid) }

    it 'processes successfully' do
      expect(subject.process(order)).to be_success
    end
  end

  context 'when order is invalid' do
    let(:order) { build(:order, :invalid) }

    it 'returns failure' do
      expect(subject.process(order)).to be_failure
    end
  end
end
```

### Subject Usage

Use named subjects for clarity:

```ruby
describe UserService do
  subject(:service) { described_class.new(user) }

  let(:user) { create(:user) }

  describe '#activate' do
    it 'activates the user' do
      expect { service.activate }.to change { user.reload.active? }.to(true)
    end
  end
end
```

### Test Doubles

Match the surrounding suite. Where the codebase already uses `double(...)`, keep it, converting
a file to `instance_double` because this guide prefers it is exactly the context-free change
that gets rejected in review. Repo precedent outranks this section.

Starting fresh, prefer the verifying doubles, which fail when the real object loses the method:

```ruby
let(:mailer) { instance_double(UserMailer, deliver_later: true) }
```

### Stubbing External APIs

Use WebMock `stub_request` for external API calls. Create reusable helpers with `_request` suffix:

```ruby
# spec/support/stubs/stripe.rb
def stub_stripe_subscription_request(subscription_id, **attributes)
  defaults = { id: subscription_id, status: "active" }
  stub_request(:get, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
    .to_return(
      status: 200,
      body: defaults.merge(attributes).to_json,
      headers: { "Content-Type" => "application/json" }
    )
end

# In specs
before { stub_stripe_subscription_request("sub_123", status: "canceled") }
```

Why HTTP-level stubs:
- Tests real parsing/error handling
- Catches URL/endpoint bugs
- No internal validation from real API objects

### Let vs Let!

```ruby
# let - lazy loaded
let(:user) { create(:user) }

# let! - immediately created
let!(:existing_user) { create(:user) }
```

## Best Practices

### Constructor Injection

```ruby
class OrderProcessor
  def initialize(payment_gateway: PaymentGateway.new)
    @payment_gateway = payment_gateway
  end
end

# In spec
let(:gateway) { instance_double(PaymentGateway) }
subject { described_class.new(payment_gateway: gateway) }
```

### Time-Dependent Tests

```ruby
it 'expires after 24 hours' do
  travel_to(Time.zone.parse('2024-01-01 12:00')) do
    token = create(:token)

    travel(25.hours)

    expect(token).to be_expired
  end
end
```

### Testing Both Cases

```ruby
describe '#valid?' do
  context 'with valid attributes' do
    it { is_expected.to be_valid }
  end

  context 'with invalid email' do
    before { subject.email = 'invalid' }

    it { is_expected.not_to be_valid }
  end
end
```

## Comments

The global no-comments rule applies to specs too. An `it` string that needs a
comment to explain it is a badly worded `it` string.

```ruby
it 'requires parental consent below the legal age' do
```

## Testing Sidekiq Jobs

Focus on failure modes and idempotency:

```ruby
describe ProcessPaymentJob do
  describe '#perform' do
    context 'when payment succeeds' do
      it 'marks order as paid' do
        expect { job.perform(order.id) }
          .to change { order.reload.status }.to('paid')
      end
    end

    context 'when payment fails' do
      before { allow(gateway).to receive(:charge).and_raise(PaymentError) }

      it 'raises to trigger Sidekiq retry' do
        expect { job.perform(order.id) }.to raise_error(PaymentError)
      end
    end

    context 'when called twice (idempotency)' do
      before { job.perform(order.id) }

      it 'does not double-charge' do
        expect { job.perform(order.id) }.not_to change { Payment.count }
      end
    end
  end
end
```

## Operator Mindset in Tests

Always test:
- Happy path
- Failure modes (external APIs, timeouts)
- Idempotency (what if this runs twice?)
- Edge cases that WILL happen in production

## Pre-Write Verification

Before writing specs, read source files to avoid assumption-based failures:

- **Request specs:** Read `config/routes.rb` for URL structure (singular vs plural, nesting)
- **Factory-dependent specs:** Read `spec/factories.rb` for default values
- **Records with specific states:** Check model validations for required attributes

## Factory Patterns

```ruby
# Bad: relies on factory default which may change
let(:user) { create(:user) }
it 'sends welcome email' do
  expect(user.email).to eq("test@example.com")  # May fail!
end

# Good: explicitly set values being tested
let(:user) { create(:user, email: "test@example.com") }
it 'sends welcome email' do
  expect(user.email).to eq("test@example.com")
end
```

## Request Spec Patterns

### Verify Routes First

```ruby
# Before writing this spec, check routes.rb:
#   resource :profile    # singular = /profile
#   resources :users     # plural = /users

# Wrong (assumed nested):
get "/api/v1/users/profile"

# Correct (verified singular resource):
get "/api/v1/profile"
```
