---
topic: KPI Definitions & Calculations
date: 2026-01-21
project: viya-reporting
sources_count: 4
status: draft
tags: [reporting, tms, kpi, metrics, otd, otif]
---

# KPI Definitions & Calculations for Shipper TMS Reporting

## Summary

This document provides precise definitions and calculation formulas for key performance indicators (KPIs) commonly used in Transportation Management Systems (TMS) for shippers. The focus is on delivery performance metrics (OTD, OTIF), transit time measurements, cost metrics, and carrier performance scorecards.

A critical finding is that **there is no universal industry standard** for many of these KPIs—definitions vary significantly across organizations, vendors, and industries. The most important consideration is consistency: once a definition is chosen, it must be applied uniformly across all measurements and clearly communicated to stakeholders. Major retailers (like Walmart) have implemented specific OTIF programs with their own tolerance windows and penalty structures, which has driven some standardization in certain supply chain segments.

The document also addresses handling of missing or incomplete data, which is essential for accurate KPI calculation in real-world scenarios where shipments may lack delivery confirmation, expected dates, or cost allocation data.

## 1. Delivery Performance KPIs

### 1.1 On-Time Delivery (OTD)

**Definition:** The percentage of shipments delivered within the expected delivery window.

**Basic Formula:**
```
OTD (%) = (Number of On-Time Deliveries / Total Number of Deliveries) × 100
```

**Key Considerations:**

| Element | Options | [CONFLICTING] Notes |
|---------|---------|---------------------|
| "On-Time" Definition | By day, by hour, within window | Organizations differ: some allow same-day, others require exact hour |
| Reference Date | Promised date vs. Requested date | Godsell research shows OTIF measured against "promise date" often fails when measured against customer "request date" |
| Tolerance Window | 0 hours to ±2 days | Retail often uses narrower windows (±4 hours); B2B may allow ±1 day |
| Early Deliveries | Count as on-time or late | Some industries penalize early (no storage); others accept |

**Calculation Variations:**

1. **Strict OTD:** Delivery exactly on the promised date
   ```
   On-Time = Actual Delivery Date = Expected Delivery Date
   ```

2. **Window-based OTD:** Delivery within a tolerance range
   ```
   On-Time = Expected Date - Tolerance ≤ Actual Date ≤ Expected Date + Tolerance
   ```

3. **No-Early OTD:** Only counts if not early
   ```
   On-Time = Expected Date ≤ Actual Date ≤ Expected Date + Tolerance
   ```

**Industry Benchmarks:**
- UK Retail sector leading practice: >97% OTIF at SKU level (Godsell & van Hoek research)
- General logistics industry: 90-95% OTD considered acceptable
- E-commerce/parcel: 95%+ expected

### 1.2 On-Time In-Full (OTIF / DIFOT)

**Definition:** A measurement of whether a shipment was delivered:
- At the expected time (On-Time)
- In the complete quantity ordered (In-Full)
- At the agreed-upon location
- Meeting quality/specification requirements

**Basic Formula:**
```
OTIF (%) = (Number of OTIF Deliveries / Total Number of Deliveries) × 100
```

**Component Breakdown:**

| Component | Definition | Measurement |
|-----------|------------|-------------|
| On-Time | Delivered within agreed window | Yes/No per delivery |
| In-Full | Complete quantity, no shortages | Actual qty ≥ Expected qty (often 100%) |
| Correct Product | Right SKU/specification | Yes/No per line item |
| Correct Location | Delivered to specified address | Yes/No per delivery |

**Calculation Methods:**

1. **By Delivery (most common):**
   ```
   OTIF = Deliveries meeting ALL criteria / Total Deliveries × 100
   ```

2. **By Order:**
   ```
   OTIF = Orders with ALL lines OTIF / Total Orders × 100
   ```

3. **By Order Line:**
   ```
   OTIF = Order lines meeting OTIF / Total Order Lines × 100
   ```

4. **[UNCERTAIN] By Quantity Percentage:**
   Some organizations calculate based on percentage of quantity delivered on-time, but this conflicts with the strict "In-Full" requirement and is not recommended.

**OTIF vs OTD:**
- OTD measures only timing
- OTIF measures timing AND completeness
- OTIF is considered superior for customer experience measurement

**Extended Metrics:**
- **DIFOTAI:** Delivery In Full, On Time, Accurately Invoiced (includes invoicing accuracy)

### 1.3 Delivery Exception Rate

**Definition:** Percentage of shipments with documented exceptions (delays, damages, refused, wrong address, etc.)

**Formula:**
```
Exception Rate (%) = (Shipments with Exceptions / Total Shipments) × 100
```

**Categories to Track:**
- Delivery delays
- Damaged goods
- Refused deliveries
- Address corrections
- Partial deliveries
- Returns at delivery

## 2. Transit Time Metrics

### 2.1 Transit Time

**Definition:** The elapsed time from shipment departure to delivery.

**Calculation:**
```
Transit Time = Delivery Date/Time - Pickup Date/Time
```

**[CONFLICTING] Start and End Points:**

| Start Point Options | End Point Options |
|--------------------|-------------------|
| Order placed | Delivered to door |
| Picked up by carrier | Signed for (POD) |
| Left shipper facility | Unloaded at destination |
| Manifest created | Available for pickup |

**Recommended Definitions for TMS:**

| Metric | Start | End |
|--------|-------|-----|
| Carrier Transit Time | Pickup scan/departure | Delivery scan/POD |
| Order-to-Delivery | Order confirmed | Delivery confirmed |
| Ship-to-Deliver | Shipment created | Delivery confirmed |

**Edge Cases:**

1. **Weekend/Holiday Handling:**
   - Option A: Include all calendar days
   - Option B: Count business days only
   - Recommendation: Use calendar days for accuracy, business days for carrier SLA

2. **Multi-leg Shipments:**
   - Measure total transit OR leg-by-leg
   - Document which is used

3. **Split Shipments:**
   - Transit time for first delivery OR last delivery OR average
   - [UNCERTAIN] No standard approach

### 2.2 Average Transit Time

**Formula:**
```
Average Transit Time = Sum of All Transit Times / Number of Shipments
```

**Variations:**
- **Median Transit Time:** More resistant to outliers
- **Transit Time by Lane:** Group by origin-destination pairs
- **Transit Time by Mode:** Separate ground, air, ocean, rail

### 2.3 Transit Time Variance

**Definition:** Consistency of transit times compared to expected.

**Formula:**
```
Transit Time Variance (%) = ((Actual Transit - Expected Transit) / Expected Transit) × 100
```

**Or Standard Deviation:**
```
σ = √(Σ(xi - μ)² / n)
```

Where:
- xi = individual transit times
- μ = average transit time
- n = number of shipments

## 3. Cost Metrics

### 3.1 Cost Per Shipment

**Definition:** Average transportation cost for each shipment.

**Basic Formula:**
```
Cost Per Shipment = Total Freight Spend / Number of Shipments
```

**What to Include:**

| Include | Exclude (typically) |
|---------|---------------------|
| Line haul/base rate | Inventory carrying costs |
| Fuel surcharge | Warehousing costs |
| Accessorial charges | Packaging materials |
| Pickup/delivery fees | Order processing costs |
| Insurance (if freight-related) | Customer service costs |
| Duties/customs (international) | Returns processing |

**Variations:**

1. **Cost Per Unit:**
   ```
   Cost Per Unit = Total Freight Spend / Total Units Shipped
   ```

2. **Cost Per Pound/Kg:**
   ```
   Cost Per Weight = Total Freight Spend / Total Weight Shipped
   ```

3. **Cost Per Mile:**
   ```
   Cost Per Mile = Total Freight Spend / Total Miles
   ```

4. **Cost as % of Sales:**
   ```
   Freight % = (Total Freight Spend / Net Sales Revenue) × 100
   ```

### 3.2 Total Freight Spend

**Definition:** Aggregate transportation expenditure over a period.

**Components:**
```
Total Freight Spend = Inbound Freight + Outbound Freight + Intercompany Transfers + Returns
```

**Tracking Dimensions:**
- By mode (truckload, LTL, parcel, air, ocean)
- By carrier
- By lane/region
- By customer/channel
- By product category

### 3.3 Freight Cost Variance

**Definition:** Difference between actual and budgeted/expected freight costs.

**Formula:**
```
Cost Variance = Actual Cost - Expected/Budgeted Cost

Variance % = ((Actual - Expected) / Expected) × 100
```

### 3.4 Accessorial Cost Percentage

**Definition:** Portion of freight spend from additional charges beyond base rates.

**Formula:**
```
Accessorial % = (Total Accessorial Charges / Total Freight Spend) × 100
```

**Common Accessorials:**
- Detention/demurrage
- Liftgate service
- Inside delivery
- Residential delivery
- Redelivery
- Storage

## 4. Carrier Performance Metrics

### 4.1 Carrier Scorecard Components

A comprehensive carrier scorecard typically includes:

| Category | Weight (typical) | Metrics |
|----------|-----------------|---------|
| Service/Delivery | 40-50% | OTD, OTIF, Transit Time Consistency |
| Cost | 20-30% | Rate competitiveness, cost variance |
| Communication | 10-15% | Tracking updates, responsiveness |
| Claims/Quality | 10-15% | Damage rate, claims ratio |
| Compliance | 5-10% | Documentation, safety |

### 4.2 Key Carrier Metrics

**Tender Acceptance Rate:**
```
Acceptance Rate (%) = (Accepted Tenders / Total Tenders) × 100
```

**Pickup Performance:**
```
Pickup On-Time (%) = (On-Time Pickups / Total Pickups) × 100
```

**Claims Ratio:**
```
Claims Ratio (%) = (Shipments with Claims / Total Shipments) × 100

Claims Cost Ratio = Total Claims Paid / Total Freight Spend × 100
```

**Damage Rate:**
```
Damage Rate (%) = (Damaged Shipments / Total Shipments) × 100
```

**Tracking Compliance:**
```
Tracking Update Rate (%) = (Shipments with Complete Tracking / Total Shipments) × 100
```

**Invoice Accuracy:**
```
Invoice Accuracy (%) = (Accurate Invoices / Total Invoices) × 100

Or: Shipments requiring rate adjustment / Total Shipments
```

### 4.3 Composite Carrier Score

**Weighted Score Calculation:**
```
Carrier Score = Σ(Metric Score × Weight)
```

**Example:**
```
Score = (OTD% × 0.35) + (Damage% × 0.15) + (Cost Index × 0.30) + (Claims% × 0.10) + (Communication × 0.10)
```

**Scoring Scale Options:**
- Percentage (0-100%)
- Letter grade (A-F)
- Points (1-5 or 1-10)
- Traffic light (Red/Yellow/Green)

## 5. Handling Missing/Incomplete Data

### 5.1 Common Data Quality Issues

| Issue | Impact | Handling Approach |
|-------|--------|-------------------|
| No delivery confirmation | Can't calculate OTD | Exclude OR assume delivered by carrier estimate |
| Missing expected date | Can't determine if on-time | Exclude from OTD calculation |
| Incomplete tracking | Transit time unknown | Use carrier-provided data OR exclude |
| Cost allocation gaps | Inaccurate cost per shipment | Prorate OR exclude incomplete records |
| Split shipments | Multiple records for one order | Consolidate OR report separately |

### 5.2 Recommended Handling Rules

**For OTD/OTIF Calculations:**
1. Require both expected and actual delivery dates
2. Document exclusion criteria clearly
3. Report "data completeness rate" alongside KPI
4. Set threshold: e.g., only report KPIs if >95% data complete

**Formula with Data Completeness:**
```
Reported OTD = OTD% (only for complete records)
Data Completeness = Complete Records / Total Records × 100
```

**For Transit Time:**
1. Require pickup AND delivery timestamps
2. Option: Use carrier-estimated delivery if no POD scan
3. Flag estimated vs. confirmed data

**For Cost Metrics:**
1. Include only fully invoiced shipments
2. Accrue estimated costs for pending invoices
3. Report based on invoice date OR ship date (choose one, be consistent)

### 5.3 Data Quality KPIs

Track data quality as its own metric:

```
Tracking Data Coverage = Shipments with Tracking / Total Shipments × 100

POD Capture Rate = Shipments with POD / Total Shipments × 100

Cost Data Completeness = Shipments with Full Cost Data / Total Shipments × 100
```

### 5.4 Imputation Strategies

[UNCERTAIN] When data is missing:

1. **Carrier-provided estimates:** Use carrier's committed transit time if actual unknown
2. **Historical averages:** Apply lane-specific averages for missing transit times
3. **Exclusion:** Most conservative—exclude incomplete records entirely
4. **Flag and include:** Include with flag indicating data quality issue

**Recommendation:** Exclusion is safest for accuracy; use imputation only if documented and consistent.

## Sources

| Source | URL | Key Contribution |
|--------|-----|-----------------|
| Wikipedia - DIFOT/OTIF | https://en.wikipedia.org/wiki/DIFOT | Core OTIF definition, calculation methods, research references (Godsell, van Hoek) |
| Godsell & van Hoek (2009) | Research cited in Wikipedia | Promise date vs. request date distinction; UK retail benchmarks |
| APICS Dictionary | Referenced in Wikipedia | Standard supply chain terminology |
| Industry practice | Multiple TMS vendor documentation | Cost metric definitions, carrier scorecard components |

## Questions for Further Research

- [ ] What specific OTIF tolerance windows do major retailers (Walmart, Target, Amazon) use?
- [ ] How do different TMS platforms handle transit time calculation for multi-modal shipments?
- [ ] Are there ISO or SCOR model standards for freight KPI definitions?
- [ ] How should environmental/sustainability metrics integrate with traditional KPIs?
- [ ] What are best practices for real-time vs. batch KPI calculation in TMS dashboards?
