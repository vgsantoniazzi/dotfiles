# Worked findings, good and bad

## Example Finding (Good)

```markdown
### F1, Must-Fix: Uncaught Promise Rejection

**Evidence:**
`src/api/orders.ts:89`
```typescript
async function processOrder(orderId: string) {
  const order = await db.orders.findById(orderId)
  await paymentService.charge(order.amount)  // No try-catch
  await db.orders.update(orderId, { status: 'paid' })
}
````

**Why It Matters:**
If `paymentService.charge()` throws, the error bubbles up as unhandled rejection.
The order remains in limbo state (not marked paid, but payment may have succeeded).
Customer gets charged but order shows as unpaid. Manual intervention required.

**Minimal Fix:**
```typescript
try {
  await paymentService.charge(order.amount)
  await db.orders.update(orderId, { status: 'paid' })
} catch (error) {
  await db.orders.update(orderId, { status: 'payment_failed', error: error.message })
  throw error  // Re-throw for caller handling
}
```

**Test That Would Catch This:**
```typescript
it('marks order as payment_failed when charge throws', async () => {
  paymentService.charge.mockRejectedValue(new Error('Card declined'))
  await expect(processOrder('order-123')).rejects.toThrow('Card declined')
  const order = await db.orders.findById('order-123')
  expect(order.status).toBe('payment_failed')
})
```
```

## Example Finding (Bad, Do Not Do This)

```markdown
### Should Consider: Error Handling

You should add try-catch blocks around async operations for better error handling.
This is a best practice that improves reliability.
```

This is bad because: no evidence, no specific location, no impact analysis, no test proposal.

---
