---
topic: Dashboard UX Patterns for TMS
date: 2026-01-21
project: viya-reporting
sources_count: 5
status: draft
tags: [reporting, tms, ux, dashboard, visualization]
---

# Dashboard UX Patterns for Shipper TMS

## Summary

Transportation Management System dashboards follow established UX patterns that prioritize exception-based workflows, geographic visualization, and drill-down navigation. The modern TMS dashboard serves as a "control tower" - a command center view that surfaces problems before they escalate while providing at-a-glance operational health.

Leading platforms like project44, FourKites, and Transporeon have converged on a common information architecture: KPI summary tiles at top, map-based visualization in the center, and exception/alert lists driving action. This pattern reflects the logistics professional's workflow: quickly assess overall health, identify problems, then drill into specifics.

Mobile responsiveness is increasingly critical as operations staff work from warehouses and in transit. The best dashboards prioritize information density on desktop while maintaining core functionality on mobile through progressive disclosure and simplified navigation.

## Common Layout Patterns

### 1. Control Tower Layout (Exception-First)

**Description:** A command-center view prioritizing exceptions and at-risk shipments. Healthy shipments fade to background; problems surface immediately.

**When to use:** Primary operational dashboard for logistics managers and coordinators. Best for teams managing 100+ shipments daily.

**Structure:**
- Top bar: Global filters (date range, customer, carrier, mode)
- Row 1: KPI tiles showing exception counts and percentages
- Row 2: Map view with color-coded shipment status
- Row 3: Exception list sorted by priority/impact
- Sidebar: Quick actions and drill-down navigation

**Competitors using this:** project44 (Movement platform), FourKites (Intelligent Control Tower)

### 2. Dashboard + List Hybrid

**Description:** Combines high-level metrics with a searchable/filterable shipment list. Users toggle between summary view and detail view.

**When to use:** When users need both overview metrics and the ability to find specific shipments quickly. Good for customer service teams.

**Structure:**
- Toggle between "Dashboard" and "List" views
- Dashboard: Summary metrics, trend charts, status distribution
- List: Sortable/filterable table with inline status indicators

### 3. Geographic-First Layout

**Description:** Map occupies primary viewport with shipments plotted. Metrics and lists overlay or appear in side panels.

**When to use:** When physical location is the primary organizing principle. Ideal for last-mile, regional delivery operations, or multi-modal shipments.

**Structure:**
- Full-width map as hero element
- Floating filters and search
- Click-to-reveal detail panels
- Collapsible side drawer for metrics

### 4. KPI Scorecard Layout

**Description:** Grid of KPI cards, each representing a key metric with trend indicators. Clicking any card drills into that metric.

**When to use:** Executive dashboards, weekly/monthly reviews, customer-facing portals. Less operational, more strategic.

**Structure:**
- Grid layout (3-4 columns on desktop)
- Each card: metric name, current value, trend arrow, sparkline
- Cards link to detailed breakdowns
- Period comparison built in (vs previous period)

## Visualization Types

### KPI Tiles / Scorecards

**Use case:** At-a-glance health indicators - on-time percentage, exception count, total shipments, cost per shipment.

**Best practices:**
- Large, readable numbers
- Color coding: green (good), yellow (warning), red (critical)
- Include comparison (vs target, vs last period)
- Trend indicators (arrows, sparklines)

**Example metrics for TMS:**
- On-Time Delivery Rate (%)
- Active Exceptions (#)
- Shipments In Transit (#)
- Cost vs Budget ($)

### Map Visualizations

**Use case:** Geographic distribution of shipments, real-time location tracking, route visualization.

**Types in TMS:**
- **Dot/Pin maps:** Individual shipment locations
- **Flow maps:** Origin-destination pairs with volume encoding
- **Heat maps:** Concentration areas, delay hotspots
- **Route maps:** Planned vs actual paths

**Best practices:**
- Use clustering for high-density areas
- Color encode status (green = on track, red = delayed)
- Show ETA vs actual arrival
- Allow zoom levels: global → region → city → individual

### Time-Series Charts

**Use case:** Trends over time - daily volumes, weekly on-time rates, cost trends.

**Types:**
- **Line charts:** Continuous metrics over time
- **Area charts:** Volume/cumulative metrics
- **Bar charts:** Discrete comparisons (by week, by carrier)

**Best practices:**
- Default to relevant time range (30 days for operational, 12 months for strategic)
- Include comparison period overlay
- Add threshold lines for targets/SLAs
- Enable date range picker

### Tables & Data Grids

**Use case:** Detailed shipment lists, carrier scorecards, cost breakdowns.

**Best practices:**
- Sortable by any column
- Inline status indicators (icons, color chips)
- Expandable rows for details
- Sticky headers for scrolling
- Export capability (CSV, Excel)
- Configurable columns for user preference

### Donut/Pie Charts

**Use case:** Part-to-whole relationships - shipments by status, volume by carrier, modes mix.

**Best practices:**
- Limit to 5-7 segments maximum
- Order by size (largest first, clockwise)
- Use sparingly - bar charts often clearer
- Good for high-level composition views

### Funnel Charts

**Use case:** Conversion-style workflows - bookings → confirmed → in-transit → delivered.

**Best practices:**
- Show counts and percentages at each stage
- Highlight drop-off points
- Link to filtered lists for each stage

## Interaction Patterns

### Drill-Down Navigation

**Pattern:** Click aggregate → see breakdown → click item → see detail.

**Implementation:**
- KPI tile → filtered list
- Map region → regional metrics → individual shipments
- Chart segment → detailed data
- Breadcrumb navigation for context

**Example flow:**
1. User sees "15 Late Shipments" KPI
2. Clicks → sees list of 15 late shipments with reasons
3. Clicks shipment → sees full shipment detail with timeline
4. Can take action (update ETA, notify customer)

### Filtering & Faceted Search

**Standard filters for TMS:**
- Date range (shipped, ETA, delivered)
- Status (booked, in-transit, delivered, exception)
- Customer / Account
- Carrier / Forwarder
- Mode (ocean, air, road, rail)
- Origin / Destination region
- Exception type

**Best practices:**
- Persist filter selections across sessions
- Show active filter count
- Quick clear / reset all
- Save filter presets

### Date Range Selection

**Common presets:**
- Today
- Last 7 days
- Last 30 days
- This month / Last month
- Custom range

**Implementation notes:**
- Clearly indicate what date field is being filtered
- Consider timezone implications
- Allow comparison periods

### Export & Sharing

**Expected exports:**
- CSV / Excel for data
- PDF for reports
- Scheduled email reports (daily/weekly digest)
- Shareable dashboard links
- Print-optimized views

### Real-Time Updates

**Patterns:**
- Auto-refresh with configurable interval (5 min default)
- Visual indicator when data is stale
- Push notifications for exceptions
- [UNCERTAIN] WebSocket vs polling depends on infrastructure - both approaches used in industry

## Mobile Considerations

### Responsive Design Priorities

**Must-have on mobile:**
- Exception alerts and counts
- Shipment search and lookup
- Individual shipment detail & tracking
- Quick actions (approve, escalate)

**Can deprioritize for mobile:**
- Complex dashboards with multiple charts
- Multi-column data grids
- Advanced filtering
- Report generation

### Mobile-Specific Patterns

1. **Card-based layouts:** Replace grids with stacked cards
2. **Bottom navigation:** Thumb-accessible primary actions
3. **Pull-to-refresh:** For real-time data updates
4. **Swipe actions:** Quick approve/dismiss/escalate
5. **Simplified maps:** Fewer layers, larger touch targets

### Progressive Disclosure

**Strategy:** Show summary on mobile, reveal details on demand.

**Example:**
- Mobile home: 3 KPI cards (exceptions, in-transit, delivered today)
- Tap exception card → list of exceptions
- Tap exception → full detail
- Desktop shows all three levels simultaneously

## Best Practices from Competitors

### project44

- **600+ exception categories** organized by priority and impact
- **MO AI Assistant** for natural language queries ("Show me late shipments to Chicago")
- **Digital twins** for real-time supply chain modeling
- Multi-modal visibility in single view
- 30% reduction in supply chain costs claimed

### FourKites

- **Intelligent Control Tower** terminology
- **Digital Workers** - AI agents automating routine decisions
- 80% reduction in manual tasks claimed
- 40% improvement in on-time delivery
- Focus on "autonomous action" - system takes action, not just alerts

### Transporeon

- **Rate benchmarking** integrated into operational views
- Carrier collaboration features
- Sustainability/emissions tracking prominent

### Common Differentiators

| Feature | Table Stakes | Differentiator |
|---------|-------------|----------------|
| Shipment tracking | Yes | - |
| Exception alerts | Yes | Priority scoring, AI categorization |
| Maps | Yes | Predictive routing, delay forecasting |
| KPIs | Yes | Custom KPI builder, AI anomaly detection |
| Exports | Yes | Scheduled reports, white-label portals |
| Mobile | Basic | Native apps, offline support |
| AI/ML | [EMERGING] | Natural language queries, autonomous actions |

## Design Principles Summary

1. **Exception-first:** Surface problems, hide healthy shipments
2. **Progressive disclosure:** Overview → breakdown → detail
3. **Consistent visual language:** Same colors for status across all views
4. **Actionable insights:** Every metric should link to action
5. **Contextual data:** Always show comparisons (target, previous period)
6. **Respect data ink ratio:** Remove decorative elements
7. **Mobile-ready:** Core functions must work on phone

## Sources

| Source | URL | Key Contribution |
|--------|-----|------------------|
| project44 Platform | https://www.project44.com/platform | Control tower architecture, exception management, AI assistant patterns |
| FourKites Intelligent Control Tower | https://www.fourkites.com/platform/ | Digital twin approach, automation workflows, KPI benchmarks |
| Geckoboard Dashboard Design Guide | https://www.geckoboard.com/best-practice/dashboard-design/ | General dashboard UX principles, data ink ratio, hierarchy |
| DataViz Project | https://datavizproject.com/ | Visualization type taxonomy and use cases |
| Exploration Plan (prior research) | research/viya-reporting/2026-01-21-exploration-plan.md | Competitive context, persona requirements |

## Questions for Further Research

- [ ] What specific exception categories are most valuable for shipper TMS? (project44's 600+ seems excessive for SMB)
- [ ] How do users actually interact with AI assistants in TMS? (Marketing claims vs reality)
- [ ] What's the optimal refresh rate for different data types?
- [ ] How should customer-facing dashboards differ from internal operations dashboards?
- [ ] What accessibility requirements apply to logistics dashboards?
