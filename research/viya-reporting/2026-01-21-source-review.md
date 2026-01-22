---
topic: Source Review - Shipper TMS Reporting
date: 2026-01-21
project: viya-reporting
status: final
tags: [source-review, validation, reporting, tms]
---

# Source Review: Shipper TMS Reporting

## Overview

This document reviews and validates sources consulted across the 8 subtopic research documents plus the initial exploration phase.

**Total unique sources consulted:** 50+
- Official documentation: 15
- Vendor marketing/product pages: 20
- Industry publications: 5
- Reference/standards: 6
- Internal Viya research: 4

## Source Quality Ranking

### Tier 1: High Reliability (Official/Standards)

| Source | Type | Used In | Key Contribution |
|--------|------|---------|------------------|
| [GHG Protocol - Scope 3](https://ghgprotocol.org/scope-3-calculation-guidance-2) | Standard | Sustainability | Foundational emissions accounting framework |
| [Smart Freight Centre - GLEC Framework](https://smartfreightcentre.org/en/our-programs/emissions-accounting/global-logistics-emissions-council/) | Standard | Sustainability | Primary logistics emissions methodology |
| [ISO 14083](https://www.iso.org/standard/78864.html) | Standard | Sustainability | International transport emissions standard |
| [Wikipedia - DIFOT/OTIF](https://en.wikipedia.org/wiki/DIFOT) | Reference | KPI Definitions | Industry-accepted definitions with academic citations |
| [Oracle TMS Documentation](https://www.oracle.com/scm/transportation-management/) | Official | Multiple | 18-year Gartner leader; ML features; industry benchmark |

### Tier 2: Medium Reliability (Reputable Vendors/Publications)

| Source | Type | Used In | Key Contribution |
|--------|------|---------|------------------|
| [project44 Platform](https://www.project44.com/platform) | Vendor | UX, Sustainability | Control tower pattern, GLEC-accredited emissions |
| [Blue Yonder TMS](https://www.blueyonder.com/solutions/transportation-management) | Vendor | SMB vs Enterprise | Enterprise capabilities, AI optimization claims |
| [FourKites Platform](https://www.fourkites.com/platform/) | Vendor | Dashboard UX | Control tower terminology, automation claims |
| [AfterShip Tracking](https://www.aftership.com/tracking) | Vendor | Customer Portals | WISMO reduction (65%), branded tracking metrics (3.2x) |
| [ShipEngine Documentation](https://www.shipengine.com/docs/) | Vendor | Customer Portals | API implementation details, branded portal setup |
| [Logistics Management](https://www.logisticsmgmt.com/) | Publication | Report Types | TMS 2026 trends article |
| [Sisense](https://www.sisense.com/) | Vendor | Self-Service BI | Embedded analytics patterns |
| [ThoughtSpot](https://www.thoughtspot.com/) | Vendor | Self-Service BI | AI analytics capabilities |
| [Databricks](https://www.databricks.com/) | Vendor | Self-Service BI | Data lakehouse architecture |

### Tier 3: Lower Reliability (Marketing/Unverified)

| Source | Type | Used In | Risk Level | Notes |
|--------|------|---------|------------|-------|
| Vendor marketing claims (40% improvement, etc.) | Marketing | Various | Medium | Performance claims unverified |
| Pricing benchmarks ($1-4/load, etc.) | Industry | SMB vs Enterprise | Medium | May be outdated |
| AI/ML capability claims | Marketing | Multiple | High | Adoption data absent |

## Cross-Source Validation

### Well-Supported Findings

| Finding | Supported By | Confidence |
|---------|--------------|------------|
| Control tower UX pattern | Oracle, project44, FourKites, Blue Yonder | High |
| Exception-first design | project44, FourKites, Transporeon | High |
| GLEC Framework as logistics standard | Smart Freight Centre, ISO, project44 | High |
| Customer portal reduces support | AfterShip (65% stat) | Medium |
| Mid-market needs simplicity | Multiple vendor positioning | Medium |
| OTD/OTIF has no universal standard | Wikipedia (academic sources), vendor variation | High |

### Conflicting Information

| Topic | Claim A | Source | Claim B | Source | Assessment |
|-------|---------|--------|---------|--------|------------|
| SMB definition | <$1M freight spend | Shipwell | <$10M freight spend | Inbound Logistics | No standard; define per context |
| Deployment time | "Days" | 3G/Descartes | "4-5 months minimum" | Oracle | Depends heavily on scope |
| AI/ML ROI | 30-40% improvements | project44, Blue Yonder | No adoption data | - | Marketing exceeds evidence |
| Exception categories | 600+ needed | project44 | Excessive for SMB | Industry practice | Start small, expand on usage |

### Single-Source Claims (Needs Verification)

| Claim | Source | Risk Level | Recommendation |
|-------|--------|------------|----------------|
| 65% WISMO reduction | AfterShip | Medium | Validate with customer research |
| 3.2x branded tracking views | AfterShip | Medium | Reasonable but single source |
| 95% EDD accuracy | AfterShip | High | AI prediction accuracy varies |
| Contrail effects 2-4x warming | Sustainability research | High | Emerging science, flag as uncertain |

## Research Gaps

Areas where adequate information could not be found:

| Gap | Importance | Suggested Next Steps |
|-----|------------|---------------------|
| Actual AI/ML adoption rates | High | Customer interviews, analyst reports |
| Mid-market customer journeys | High | Customer research |
| European regulatory timelines | Medium | Legal/compliance research |
| Accessibility requirements | Medium | WCAG review, industry standards |
| BI tool market share among shippers | Medium | Analyst reports (Gartner, Forrester) |
| B2B portal authentication patterns | Low | Security architecture research |

## Temporal Relevance

| Source | Published | Topic Area | Still Relevant? | Notes |
|--------|-----------|------------|-----------------|-------|
| GLEC Framework v3.2 | Oct 2025 | Sustainability | Yes | Current version |
| ISO 14083 | Mar 2023 | Sustainability | Yes | Current standard |
| Logistics Management TMS 2026 | Jan 2026 | Trends | Yes | Current year |
| GHG Protocol Scope 3 | 2022 revision | Emissions | Yes | Foundational standard |
| Vendor documentation | 2025-2026 | Features | Mostly | Marketing evolves faster than reality |

### Outdated Information Warnings

- **TMS pricing benchmarks**: Market prices shift; validate current pricing
- **AI capability claims**: Evolving rapidly; revalidate quarterly
- **Regulatory deadlines**: EU CSRD, SEC rules in flux; monitor updates

## Methodology Notes

- **Discovery phase**: 3 broad web searches, memory check, Notion search
- **Subtopic research**: 8 parallel research agents with focused searches
- **Sources per subtopic**: 4-8 unique sources
- **Date range of sources**: 2022-2026 (prioritized recent)
- **Vendor bias mitigation**: Cross-referenced vendor claims against industry publications and standards

## Source Reliability Criteria

| Rating | Meaning | Examples |
|--------|---------|----------|
| **High** | Official standards, peer-reviewed, established authority | ISO, GHG Protocol, academic papers |
| **Medium** | Reputable vendor documentation, industry publications | Oracle docs, Logistics Management |
| **Low** | Marketing claims, unverified statistics | Performance improvement percentages |
| **Uncertain** | Emerging/evolving, single source | AI adoption rates, new regulatory requirements |

---

*Review completed: 2026-01-21*
