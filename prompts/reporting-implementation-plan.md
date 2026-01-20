# Prompt: Reporting & Materialized Views Implementation Plan

Use this prompt in viya-app (with MongoDB MCP enabled) to create an implementation plan for reporting materialized views.

---

## Prompt

```
I need help creating an implementation plan for TMS reporting materialized views in our MongoDB database.

## Context

We've researched TMS reporting best practices and competitor features. Key findings:

**Table Stakes Reports (must have):**
- Shipment volume dashboard with trends
- Carrier performance scorecards (OTD %, volume, cost)
- Exception/alert management
- Geographic distribution (origin/destination)
- Cost/spend analysis

**Differentiators (competitive advantage):**
- Sustainability/carbon reporting
- 90-day trend visualizations
- Customer-facing tracking portals

**Proposed Materialized Views:**

1. `mv_shipments_daily` - Daily aggregations by carrier, lane, service level
   - shipmentCount, confirmedCount, deliveredCount
   - totalWeight, totalCost, avgCostPerShipment
   - Dimensions: date, carrier, serviceLevel, originCountry, destCountry

2. `mv_carrier_performance` - Monthly carrier scorecards
   - Volume, status breakdown, OTD rate
   - avgTransitDays, totalCost

3. `mv_lanes_summary` - Origin-destination lane analysis
   - Volume, cost, transit time by lane
   - Carrier breakdown per lane

4. `mv_shipment_events` - Lifecycle tracking per shipment
   - Timestamps: created, ordered, confirmed, delivered
   - SLA compliance: deliveredOnTime, deliveryVarianceDays

5. `mv_operations_current` - Real-time operations snapshot
   - Today's counts, pending work, exceptions

## Your Tasks

1. **Explore the current database:**
   - List collections in the shipping database
   - Show me the schema of the `shipments` collection
   - Check what existing analytics/mv_* collections exist and their schemas
   - Count documents in key collections

2. **Validate the MV designs:**
   - Can we build mv_shipments_daily with the current schema?
   - What fields are we missing for OTD calculation?
   - Show me a sample aggregation pipeline for the daily summary

3. **Create an implementation plan:**
   - What order should we implement these?
   - What indexes do we need?
   - How should we handle refresh (batch vs change streams)?
   - Are there any schema gaps we need to address first?

4. **Propose the first MV implementation:**
   - Write the aggregation pipeline for mv_shipments_daily
   - Include the $merge stage for upsert behavior
   - Show me the index recommendations

Start by exploring the database to understand what we're working with.
```

---

## Prerequisites

Make sure you have MongoDB MCP configured in `viya-app/opencode.json`:

```json
{
  "mcp": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "mongodb://localhost:27017/shipping"
      }
    }
  }
}
```

And MongoDB running:
```bash
cd dev && docker compose up -d mongodb
```

---

## Expected Outcome

The AI should:
1. Explore the shipping database using MCP tools
2. Validate which proposed MVs can be built with current data
3. Identify any gaps (e.g., missing delivery timestamps)
4. Produce a phased implementation plan
5. Write working aggregation pipelines

---

## Follow-up Prompts

After the initial plan:

```
Now implement mv_shipments_daily:
1. Create the aggregation pipeline
2. Add the necessary indexes
3. Run it and show me sample output
4. Suggest how to set up the refresh job
```

```
Show me what a dashboard query would look like to get:
- Daily shipment volume for the last 30 days
- Carrier comparison for this month
- Top 10 destination countries
```

```
What would we need to add carbon/emissions estimates to the daily summary?
Research typical emission factors for parcel shipping by carrier/mode.
```
