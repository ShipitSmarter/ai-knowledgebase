# MongoDB Performance Research

Research on MongoDB performance optimization strategies for Viya TMS microservices.

## Documents

| Date | Document | Status |
|------|----------|--------|
| 2026-01-28 | [MongoDB Performance Optimization](./2026-01-28-mongodb-performance-optimization.md) | Draft |

## Context

Viya TMS uses MongoDB Atlas as its primary database across microservices (shipping, rates, authorizing, etc.). Performance optimization is critical as datasets grow to hundreds of thousands of records per tenant.

## Key Topics

- Index strategy and management
- Query optimization patterns
- Document design for performance
- N+1 query detection and prevention
- Testing with production-scale data
