---
topic: Sustainability & Emissions Reporting
date: 2026-01-21
project: viya-reporting
sources_count: 8
status: draft
tags: [reporting, tms, sustainability, emissions, carbon, scope3]
---

# Sustainability & Emissions Reporting in Shipper TMS

## Summary

Sustainability and emissions reporting has become a critical capability for Transportation Management Systems, driven by regulatory requirements (EU CSRD, SEC climate rules), customer demand for carbon footprint data, and corporate net-zero commitments. The logistics industry has converged on the **GLEC Framework** (Global Logistics Emissions Council) as the primary methodology, which has now been formalized as **ISO 14083** (published March 2023) - the internationally recognized standard for quantifying and reporting GHG emissions from transport operations.

For shippers using a TMS, emissions reporting falls under **Scope 3, Category 4 (Upstream Transportation and Distribution)** of the GHG Protocol. The key challenge is obtaining accurate data - most implementations use a tiered approach starting with emission factor-based estimates (using default factors per transport mode/distance) and evolving toward actual fuel consumption data from carriers. Modern TMS platforms like project44 offer GLEC-accredited emissions calculations integrated with shipment visibility.

A pragmatic v1 implementation should focus on providing shipment-level CO2e estimates using industry-standard emission factors, aggregate reporting by carrier/lane/mode, and exportable data for corporate sustainability reports. The accuracy vs. effort tradeoff means most shippers start with "modeled" estimates (using default factors) before pursuing "reported" data directly from carriers.

## Industry Standards

### GHG Protocol - Scope 3 Framework

The **GHG Protocol** is the foundational corporate accounting standard, dividing emissions into three scopes:

- **Scope 1**: Direct emissions from owned/controlled sources
- **Scope 2**: Indirect emissions from purchased electricity
- **Scope 3**: All other indirect emissions in the value chain (15 categories)

For logistics/TMS purposes, the relevant categories are:
- **Category 4**: Upstream transportation and distribution (inbound freight)
- **Category 9**: Downstream transportation and distribution (outbound freight)

The GHG Protocol Scope 3 Calculation Guidance provides methods for calculating emissions for each category, including transportation. It recommends using actual data where available, with emission factors as a fallback.

### GLEC Framework

The **Global Logistics Emissions Council (GLEC) Framework** is the primary industry guideline for logistics emissions accounting, developed by Smart Freight Centre. Key points:

- **Purpose**: Harmonize calculation and reporting of logistics GHG emissions across multi-modal supply chains
- **Scope**: Covers all transport modes (road, rail, ocean, air) and logistics sites
- **Compatibility**: Works with GHG Protocol, CDP Reporting, UN Global Green Freight Action Plan
- **Current Version**: GLEC Framework v3.2 (updated October 2025)
- **Accreditation**: SFC offers certification for tools and programs implementing the framework

The GLEC Framework provides:
- Standardized emission factors by transport mode
- Allocation methods for shared transport
- Guidance on data quality tiers
- Reporting templates and declarations

### ISO 14083

**ISO 14083:2023** ("Quantification and reporting of greenhouse gas emissions of transport operations") is the formal ISO standard built on the GLEC Framework:

- **Published**: March 2023
- **Significance**: First globally recognized ISO standard for transport emissions
- **Relationship**: GLEC Framework serves as the primary implementation guideline for ISO 14083
- **Acceptance**: Enables consistent adoption by industry, governments, and investors

Key principles from ISO 14083:
1. Well-to-wheel emissions accounting (includes fuel production)
2. Allocation based on weight-distance or other appropriate metrics
3. Multiple data quality levels supported
4. Interoperability across supply chain partners

## Calculation Methodologies

### Three-Tier Approach

The GLEC Framework and ISO 14083 define three tiers of data quality:

| Tier | Data Source | Accuracy | Typical Use |
|------|-------------|----------|-------------|
| **Tier 1** (Default) | Default emission factors | Low-Medium | Starting point, rough estimates |
| **Tier 2** (Modeled) | Mode/vehicle-specific factors + actual distance | Medium | Most common in TMS |
| **Tier 3** (Reported) | Actual fuel consumption from carrier | High | Preferred, requires carrier data sharing |

### Basic Calculation Formula

```
CO2e = Activity Data x Emission Factor
```

Where:
- **Activity Data**: Distance traveled, weight transported, or fuel consumed
- **Emission Factor**: CO2e per unit of activity (e.g., kg CO2e per tonne-km)

### Mode-Specific Considerations

**Road Freight**:
- Factors vary by vehicle type (LTL vs FTL), fuel type, load factor
- Default: ~62-100 g CO2e/tonne-km for trucking
- Actual fuel consumption preferred when available

**Ocean Freight**:
- Factors vary by vessel type, route, and cargo type
- Container shipping: ~10-20 g CO2e/tonne-km (much lower than road)
- Clean Cargo Working Group provides carrier-specific factors

**Air Freight**:
- Highest emissions per tonne-km (~500-1000 g CO2e/tonne-km)
- Belly cargo vs. freighter allocation is complex
- [UNCERTAIN] Contrail effects may multiply warming impact 2-4x

**Rail**:
- Lowest emissions for land transport (~20-30 g CO2e/tonne-km)
- Electric rail significantly lower than diesel

### Allocation Methods

When transport is shared (LTL, container shipping), emissions must be allocated:

1. **Weight-based**: Proportional to cargo weight
2. **Volume-based**: Proportional to cargo volume/space used
3. **Weight-distance**: Most common (tonne-kilometers)
4. **Revenue-based**: Proportional to shipping cost (less preferred)

## Data Requirements

### Minimum Data Required (Tier 2)

For basic emissions estimates, a TMS needs:

| Data Point | Source | Purpose |
|------------|--------|---------|
| Origin/Destination | Shipment record | Calculate distance |
| Transport mode | Booking/shipment | Select emission factor |
| Weight | Shipment record | Calculate tonne-km |
| Carrier | Booking | Optional: carrier-specific factors |

### Enhanced Data (Tier 3)

For higher accuracy:

| Data Point | Source | Purpose |
|------------|--------|---------|
| Actual fuel consumption | Carrier reporting | Direct calculation |
| Vehicle type/class | Carrier | Vehicle-specific factor |
| Load factor | Carrier | Allocate shared transport |
| Fuel type | Carrier | Fuel-specific emission factor |
| Route details | Visibility/tracking | Actual distance vs. estimate |

### Data Quality Challenges

[UNCERTAIN] Key limitations identified in industry practice:

1. **Carrier data availability**: Most carriers don't share actual fuel consumption
2. **LTL allocation**: Complex to determine fair share in consolidated shipments
3. **Multi-leg journeys**: Tracking emissions across handoffs
4. **Empty miles**: Whether to allocate return trip emissions
5. **Well-to-wheel boundaries**: Upstream fuel production emissions often estimated

## Competitor Implementations

### project44 Emissions Monitoring

project44 offers a mature emissions monitoring solution integrated with their visibility platform:

**Features**:
- GLEC-accredited emissions calculations
- Shipment-level CO2e, emissions intensity, and distance
- Multi-modal support (ocean, road, air, rail)
- Sustainability dashboard with carrier/lane/region breakdowns
- Custom reporting and data export

**Key Claims**:
- "Powered by the world's largest transportation dataset"
- Scope 3 compliance support
- Historical emissions data for trend analysis

### Flexport

Flexport has positioned sustainability as a core differentiator:

**Features**:
- Integrated carbon footprint calculator
- Emissions displayed on every shipment
- Carbon offset purchasing option

[Note: Flexport's "Open Emissions Calculator" mentioned in discovery was not directly accessible for detailed review]

### Other Competitors

**Transporeon**: Emissions visibility module integrated with freight marketplace

**SAP TM**: Carbon footprint calculation built into transportation management

[UNCERTAIN] **Oracle TM**: Sustainability features - limited public documentation found

## Recommendations for v1 Implementation

### Phased Approach

**Phase 1: Basic Estimates (MVP)**

1. **Emission factor database**: Integrate GLEC Framework default factors by mode
2. **Shipment-level calculation**: CO2e per shipment using distance x weight x factor
3. **Basic reporting**: Total emissions, emissions per shipment, by mode
4. **Export**: CSV/Excel for integration with corporate sustainability reports

**Phase 2: Enhanced Accuracy**

1. **Carrier-specific factors**: Allow carriers to provide their own emission factors
2. **Route refinement**: Use actual tracking data vs. great-circle estimates
3. **Vehicle type differentiation**: Different factors for LTL vs. FTL, etc.
4. **Dashboard**: Trends, comparisons, drill-down capabilities

**Phase 3: Advanced Features**

1. **Tier 3 data integration**: Accept actual fuel consumption from carriers
2. **ISO 14083 certification**: Pursue SFC accreditation
3. **Carbon reduction recommendations**: Route optimization, mode shift analysis
4. **Integration**: Connect to carbon accounting platforms, ESG reporting tools

### Technical Considerations

**Data Model**:
- Store emission factors as configurable reference data
- Calculate and persist CO2e at shipment level
- Aggregate for reporting (don't recalculate each time)
- Track calculation methodology/version for audit trail

**Emission Factor Sources**:
- GLEC Framework v3.2 (primary)
- Clean Cargo (ocean-specific)
- EPA emission factors (US-specific)
- Allow customer override for carrier-specific data

**Reporting Dimensions**:
- By shipment, by carrier, by lane, by customer
- By transport mode
- By time period (month, quarter, year)
- Emissions intensity (CO2e per tonne-km, per shipment)

### Compliance Considerations

[CONFLICTING] Standards are still evolving:
- EU CSRD requires reporting but methodology details pending
- SEC climate disclosure rules implementation uncertain
- GLEC Framework and ISO 14083 are aligned but differences exist in some details

**Recommendation**: Follow GLEC Framework/ISO 14083 as the safe path - industry-accepted and regulatory-aligned.

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| GHG Protocol - Scope 3 Calculation Guidance | https://ghgprotocol.org/scope-3-calculation-guidance-2 | Foundational framework, 15 categories, calculation methods |
| Smart Freight Centre - GLEC Framework | https://smartfreightcentre.org/en/our-programs/emissions-accounting/global-logistics-emissions-council/calculate-report-glec-framework/ | Primary logistics emissions methodology, v3.2 current |
| Smart Freight Centre - ISO 14083 | https://smartfreightcentre.org/en/our-programs/emissions-accounting/global-logistics-emissions-council/iso-standard-building-on-glec-framework/ | ISO standard relationship to GLEC |
| project44 Sustainability | https://www.project44.com/platform/visibility/sustainability/ | Competitor implementation, GLEC-accredited tool |
| GHG Protocol - Category 4 Guidance | https://ghgprotocol.org/sites/default/files/2022-12/Chapter4.pdf | Upstream transportation calculation details |
| PCAF Standard | https://carbonaccountingfinancials.com/en/standard | Financial sector GHG accounting (context for customer requirements) |
| Smart Freight Centre Homepage | https://smartfreightcentre.org/en/ | Organization context, programs overview |
| ISO 14083 Overview | https://www.iso.org/standard/78864.html | ISO standard reference (content not fully accessible) |

## Questions for Further Research

- [ ] How do customers currently receive emissions data from their carriers?
- [ ] What specific GLEC emission factors should be used for European vs. US operations?
- [ ] What's the business case for SFC certification/accreditation vs. self-attestation?
- [ ] How should emissions be allocated for consolidated/LTL shipments in Viya's data model?
- [ ] What's the integration approach with customer ERP/sustainability reporting tools?
- [ ] Are there specific regulatory deadlines driving urgency (EU CSRD timeline)?
